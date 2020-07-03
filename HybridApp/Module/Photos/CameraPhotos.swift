//
//  CameraPhotos.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

import Photos
import MobileCoreServices
import DKImagePickerController // 이미지 다중선택

struct ModuleType {
    static let camera = "Camera"
    static let photos = "Photos"
}
/*
 카메라 및 앨범 관련 동작 수행
 */
class CameraPhotos : NSObject {
    
    private let currentVC : UIViewController
    private let dialog = Dialog()
    private var flagImageSave = false
    private var imageAction : FlexAction? = nil
    private var ratio : CGFloat!
    private var imagePicker: UIImagePickerController!
    private var isWidth : Bool? = nil
    private var newSize: CGSize!
    private let loadingView : LoadingView!
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
        self.loadingView = LoadingView(currentVC.view)
        super.init()
        self.imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    func cameraFunction() -> (FlexAction, Array<Any?>) -> Void {
        return { (action, arguments) -> Void in
            
            Utils.setUserHistory(forKey: "CameraBtn")
            
            self.ratio = arguments[0] as? CGFloat
            if arguments.count > 1 {
                self.isWidth =  arguments[1] as? Bool
            }
            
            var result = Utils.genResult()

            let cameraAuthorizationsStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch cameraAuthorizationsStatus {
            case .authorized :
                self.imageAction = action
                self.cameraPhotosAction(ModuleType.camera)
            case .denied :
                Utils.setAuthAlertAction(currentVC : self.currentVC,  dialog: Utils.authDialog)
                result["msg"] = AuthrizeStatus.denied
                action.promiseReturn(result)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
                    if response {
                        self.imageAction = action
                        self.cameraPhotosAction(ModuleType.camera)
                    } else {
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: ["basic": "확인"] , type : true, animated : true, promiseAction : nil)
                        result["msg"] = AuthrizeStatus.denied
                        action.promiseReturn(result)
                    }
                }
            case .restricted:
                result["msg"] = AuthrizeStatus.restricted
                action.promiseReturn(result)
            default:
                result["msg"] = Msg.UnknownError
                action.promiseReturn(result)
            }
        }
    }
    
    //Photos를 실행시키는 모듈
    func photosFunction() -> (FlexAction, Array<Any?>) -> Void  {
        return { (action, arguments) -> Void in
            Utils.setUserHistory(forKey: "PhotoBtn")
            
            self.ratio = arguments[0] as? CGFloat
            if arguments.count > 1 {
                self.isWidth =  arguments[1] as? Bool
            }
            
            var result = Utils.genResult()
            
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus{
            case .authorized:
                self.imageAction = action
                self.cameraPhotosAction(ModuleType.photos)
            case .denied:
                result["msg"] = AuthrizeStatus.denied
                action.promiseReturn(result)
                Utils.setAuthAlertAction(currentVC : self.currentVC,  dialog: Utils.authDialog)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(status) in
                    switch status {
                    case .authorized :
                        self.imageAction = action
                        self.cameraPhotosAction(ModuleType.photos)
                    case .denied :
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: ["basic": "확인"] , type : true, animated : true, promiseAction: nil)
                        result["msg"] = AuthrizeStatus.denied
                        action.promiseReturn(result)
                    default:
                        result["msg"] = Msg.UnknownError
                        action.promiseReturn(result)
                    }
                })
            case .restricted:
                result["msg"] = AuthrizeStatus.restricted
                action.promiseReturn(result)
            default:
                result["msg"] = Msg.UnknownError
                action.promiseReturn(result)
            }
        }
    }
    
    //사진 여러장 선택
    func MultiplePhotosFunction() -> (FlexAction, Array<Any?>) -> Void {
        return { (action, arguments) -> Void in
            
            Utils.setUserHistory(forKey: "MultiplePhotoBtn")
            self.imageAction = action
            
            var result = Utils.genResult()
            result["auth"] = true
            
            self.ratio = arguments[0] as? CGFloat
            if arguments.count > 1 {
                self.isWidth =  arguments[1] as? Bool
            }
            
            var imageArray = [DKAsset]()
            var multiImageArray = [String]()
            
            DispatchQueue.main.async {
                let multiPicker = DKImagePickerController()
                multiPicker.maxSelectableCount = 10
                multiPicker.showsCancelButton = true
                multiPicker.allowsLandscape = false
                multiPicker.assetType = .allPhotos
                multiPicker.didCancel = {
                    result["msg"] = Msg.Cancel
                    self.imageAction?.promiseReturn(result)
                }
                multiPicker.maxSelectableCount = 5
                multiPicker.viewWillAppear(true)
                multiPicker.didSelectAssets = { (assets : [DKAsset]) in
                    DispatchQueue.main.async {
                        DispatchQueue(label: "indicatorQueue").async {
                            self.loadingView.showActivityIndicator(text: Msg.Loading, nil )
                        }
                        DispatchQueue(label: "indicatorQueue").async {
                            imageArray.append(contentsOf: assets)
                            multiImageArray = imageArray.map {
                                let captureImage = self.getAsset(asset: $0.originalAsset.self!)
                                let resizeImageg = self.resizeImage(image: captureImage, ratio: self.ratio, isWidth: self.isWidth)
                                let imageData : NSData = resizeImageg.jpegData(compressionQuality: 0.25)! as NSData
                                let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                                let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                                return "data:image/jpeg;base64," + encodedString
                            }
                            result["data"] = multiImageArray
                            self.imageAction?.promiseReturn(result)
                            self.loadingView.stopActivityIndicator()
                        }
                    }
                }
                self.currentVC.present(multiPicker, animated : true)
            }
        }
    }
}

extension CameraPhotos :  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func cameraPhotosAction( _ type : String) -> Void {
        var result = Utils.genResult()
        result["auth"] = true
        DispatchQueue.main.async {
            switch type {
            case ModuleType.camera:
                if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                    self.flagImageSave = true
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.mediaTypes = [kUTTypeImage as String]
                
                    self.currentVC.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    result["msg"] = Msg.NoCamera
                    self.imageAction?.promiseReturn(result)
                    self.dialog.makeDialog(self.currentVC, title : "경고", message : "카메라를 실행할 수 없습니다." , btn: ["basic": "확인"] , type : true, animated : true, promiseAction: nil)
                }
            case ModuleType.photos:
                if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                    self.flagImageSave = false
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.mediaTypes = [kUTTypeImage as String]
                   
                    self.currentVC.present(self.imagePicker, animated: true, completion: nil)
                }else{
                    result["msg"] = Msg.NoPhotos
                    self.imageAction?.promiseReturn(result)
                    self.dialog.makeDialog(self.currentVC, title : "경고", message : "사진을 실행할 수 없습니다." , btn: ["basic": "확인"] , type :true, animated : true, promiseAction: nil)
                }
            default:
                result["msg"] = Msg.UnknownError
                self.imageAction?.promiseReturn(result)
            }
        }
    }
    
    // 사진 한장 선택
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.loadingView.showActivityIndicator(text: Msg.Loading, nil)
        self.currentVC.dismiss(animated: true){
            let captureImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let resizedImage = self.resizeImage(image: captureImage, ratio: self.ratio, isWidth: self.isWidth)
            if self.flagImageSave {
                UIImageWriteToSavedPhotosAlbum(resizedImage, self, nil, nil)
            }
            let imageData:NSData = resizedImage.jpegData(compressionQuality: 0.25)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
            
            var result = Utils.genResult()
            result["auth"] = true
            result["data"] = "data:image/jpeg;base64," + encodedString
            self.imageAction?.promiseReturn(result)
            self.loadingView.stopActivityIndicator()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentVC.dismiss(animated: true) {
            var result = Utils.genResult()
            result["auth"] = true
            result["msg"] = Msg.Cancel
            self.imageAction?.promiseReturn(result)
        }
    }

    //PHAsset -> UIImage 변환
    func getAsset(asset: PHAsset) -> UIImage {
        var image = UIImage()
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        imgManager.requestImage(for: asset, targetSize: CGSize(width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height), contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (img, _) in
            image = img!
        })
        return image
    }
    
    func resizeImage(image: UIImage, ratio : CGFloat, isWidth : Bool?) -> UIImage {
        let imageSize = image.size
        var width : CGFloat
        var height : CGFloat
        let deviceSize = UIScreen.main.bounds.size
        
        if let deviceRat = isWidth {
            
            if deviceRat {
                 width  = deviceSize.width * ratio
                 height = (width * imageSize.height) / imageSize.width
            } else {
                 height  = deviceSize.height * ratio
                 width = (height * imageSize.width) / imageSize.height
            }
        } else {
             width  = imageSize.width * ratio
             height = imageSize.height * ratio
        }
       
        newSize = CGSize(width: width , height: height)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
