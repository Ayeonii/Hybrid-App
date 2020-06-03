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

enum ModuleType : String{
    case camera = "Camera"
    case photos = "Photos"
}
/*
 카메라 및 앨범 관련 동작 수행
 */
class CameraPhotos : NSObject {
    
    private let util = Utils()
    private let currentVC : UIViewController
    private let dialog = Dialog()
    private var flagImageSave = false
    private var imageAction : FlexAction? = nil
    private var ratio : CGFloat!
    private var imagePicker: UIImagePickerController!
    private var isWidth : Bool? = nil
    private var newSize: CGSize!
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
        super.init()
        self.imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    func cameraFunction() -> (FlexAction, Array<Any?>) -> Void? {
        return { (action, arguments) -> Void in
            
            self.util.setUserHistory(forKey: "CameraBtn")
            
            self.ratio = arguments[0] as? CGFloat
            if arguments.count > 1 {
                self.isWidth =  arguments[1] as? Bool
            }
            
            var auth = false
            
            var returnStr : String?
            let cameraAuthorizationsStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch cameraAuthorizationsStatus {
            case .authorized :
                auth = true
                self.imageAction = action
                returnStr = AuthrizeStatus.authorized.rawValue
                self.cameraPhotosAction(ModuleType.camera.rawValue)
            case .denied :
                returnStr = AuthrizeStatus.denied.rawValue
                self.util.setAuthAlertAction(currentVC : self.currentVC,  dialog: self.util.authDialog)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
                    if response {
                        auth = true
                        self.imageAction = action
                        self.cameraPhotosAction(ModuleType.camera.rawValue)
                    }else {
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: ["basic": "확인"] , type : true, animated : true, promiseAction : nil)
                        returnStr = AuthrizeStatus.denied.rawValue
                    }
                }
            case .restricted:
                returnStr = AuthrizeStatus.restricted.rawValue
            default:
                returnStr = "default"
                break
            }
            if !auth {
                action.PromiseReturn(nil)
            }
            if let printStr = returnStr {
                print(printStr)
            }
        }
    }
    
    //Photos를 실행시키는 모듈
    func photosFunction() -> (FlexAction, Array<Any?>) -> Void?  {
        return { (action, arguments) -> Void in
            
            self.util.setUserHistory(forKey: "PhotoBtn")
            
            self.ratio = arguments[0] as? CGFloat
            if arguments.count > 1 {
                self.isWidth =  arguments[1] as? Bool
            }
            
            var auth = false

            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            var returnStr : String?
            switch photoAuthorizationStatus{
            case .authorized:
                returnStr = AuthrizeStatus.authorized.rawValue
                auth = true
                self.imageAction = action
                self.cameraPhotosAction(ModuleType.photos.rawValue)
            case .denied:
                returnStr = AuthrizeStatus.denied.rawValue
                self.util.setAuthAlertAction(currentVC : self.currentVC,  dialog: self.util.authDialog)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(status) in
                    switch status {
                    case .authorized :
                        returnStr = AuthrizeStatus.authorized.rawValue
                        auth = true
                        self.imageAction = action
                        self.cameraPhotosAction(ModuleType.photos.rawValue)
                    case .denied :
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: ["basic": "확인"] , type : true, animated : true, promiseAction: nil)
                        returnStr = AuthrizeStatus.denied.rawValue
                    default:
                        break
                    }
                })
            case .restricted:
                returnStr = AuthrizeStatus.restricted.rawValue
            default :
                returnStr = "default"
                break
            }
            if !auth {
                action.PromiseReturn(nil)
            }
            if let printStr = returnStr {
                print(printStr)
            }
        }
    }
    
    //사진 여러장 선택
    func MultiplePhotosFunction() -> (FlexAction, Array<Any?>) -> Void?{
        return { (action, arguments) -> Void in
            
            self.util.setUserHistory(forKey: "MultiplePhotoBtn")
            self.imageAction = action
            
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
                multiPicker.didSelectAssets = { (assets : [DKAsset]) in
                    imageArray.append(contentsOf: assets)
                    
                    multiImageArray = imageArray.map {
                        let captureImage = self.getAsset(asset: $0.originalAsset.self!)
                        let imageData:NSData = captureImage.jpegData(compressionQuality: 0.25)! as NSData
                        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                        let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                        
                        return "data:image/jpeg;base64," + encodedString
                    }
                    self.imageAction!.PromiseReturn(multiImageArray)
                }
                
                self.currentVC.present(multiPicker, animated : true)
            }
        }
    }
}

extension CameraPhotos :  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func cameraPhotosAction( _ type : String) -> Void {
        DispatchQueue.main.async {
            switch type {
            case "Camera":
                if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                    self.flagImageSave = true
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.mediaTypes = [kUTTypeImage as String]
                    self.imagePicker.allowsEditing = false
                    
                    self.currentVC.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    self.imageAction?.PromiseReturn(nil)
                    self.dialog.makeDialog(self.currentVC, title : "경고", message : "카메라에 접근할 수 없습니다" , btn: ["basic": "확인"] , type : true, animated : true, promiseAction: nil)
                }
                break
            case "Photos":
                if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                    self.flagImageSave = false
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.mediaTypes = [kUTTypeImage as String]
                    self.imagePicker.allowsEditing = true
                    
                    self.currentVC.present(self.imagePicker, animated: true, completion: nil)
                }else{
                    self.imageAction?.PromiseReturn(nil)
                    self.dialog.makeDialog(self.currentVC, title : "경고", message : "Photos에 접근할 수 없습니다" , btn: ["basic": "확인"] , type :true, animated : true, promiseAction: nil)
                }
                break
            default:
                break
            }
        }
    }
    
    // 사진 한장 선택
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.currentVC.dismiss(animated: true){
            let captureImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
           // let resizedImage = self.resizeImage(image: captureImage, ratio: self.ratio, isWidth: self.isWidth)
            if self.flagImageSave {
                UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
            }
            let imageData:NSData = captureImage.jpegData(compressionQuality: 0.25)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
            self.imageAction?.PromiseReturn("data:image/jpeg;base64," + encodedString)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentVC.dismiss(animated: true) {
            self.imageAction?.PromiseReturn("Cancel")
        }
    }
    
    
    
    //PHAsset -> UIImage 변환
    func getAsset(asset: PHAsset) -> UIImage {
        var image = UIImage()
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        imgManager.requestImage(for: asset, targetSize: CGSize(width: newSize.width , height: newSize.height), contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (img, _) in
            image = img!
        })
        return image
    }
    
    
    func resizeImage(image: UIImage, ratio : CGFloat, isWidth : Bool?) -> UIImage {
        let imageSize = image.size
        var width : CGFloat
        var height : CGFloat
        let deviceSize = currentVC.view.frame.size
        
        if let deviceRat = isWidth {
           // let deviceSize = UIScreen.main.bounds
            if deviceRat {
                 width  = deviceSize.width * ratio //이미지가로사이즈 deviceSize.width - width / deviceSize.width)
                 height = (width * imageSize.height) / imageSize.width//이미지세로사이즈
            } else {
                 height  = deviceSize.height * ratio
                width = (height * imageSize.width) / imageSize.height
            }
        } else {
             width  = imageSize.width * ratio//이미지가로사이즈
             height = imageSize.height * ratio //이미지세로사이즈
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
