//
//  Utils.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

#if canImport(CoreNFC)
import CoreNFC //NFC
#endif

//공통
import UIKit
import FlexHybridApp

//카메라/앨범
import Photos
import MobileCoreServices
import DKImagePickerController // 이미지 다중선택

import CoreLocation     //위치

import LocalAuthentication //사용자인증

import AVFoundation    //Network / QR 코드
import SystemConfiguration

import MessageUI

import UserNotifications


enum AuthrizeStatus : String {
    case authorized = "Access Authorized."
    case denied = "Access Denied"
    case restricted = "Access Restricted"
    case disabled = "Access disabled"
    case error = "Error"
}

/*
    공통사용기능
*/
class Utils: NSObject {

    let authDialog = UIAlertController (title : "권한요청", message : "권한을 허용해야만 해당 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
    
    //권한설정 버튼 다이얼로그
    func setAuthAlertAction(currentVC : UIViewController, dialog : UIAlertController){
        var actions : Array<UIAlertAction>? = []
        
        let getAuthBtnAction = UIAlertAction(title : "설정", style: .default) {(UIAlertAction) in
            if let appSettings = URL(string : UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options : [:], completionHandler: nil)
            }
        }
        let cancelBtnAction = UIAlertAction(title : "취소", style: .destructive, handler: nil)
        
        actions?.append(getAuthBtnAction)
        actions?.append(cancelBtnAction)
        
        self.alertDialog(currentVC : currentVC, dialog: dialog, animated: true,  action : actions, completion: nil)
    }
    
    //메인스레드에서 처리하기 위한 알럿 다이얼로그
    func alertDialog (currentVC : UIViewController, dialog: UIAlertController, animated: Bool, action : Array<UIAlertAction>?, completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            if let size = action {
                if dialog.actions.isEmpty{
                    for i in 0 ..< size.count {
                        dialog.addAction(size[i])
                    }
                }
            }
            currentVC.present(dialog, animated: animated, completion: completion)
        }
    }
}

enum ModuleType : String{
    case camera = "Camera"
    case photos = "Photos"
}

/*
    카메라 및 앨범 관련 동작 수행
 */
class CameraPhotos : NSObject {
    
   private let viewController = ViewController()
       private let util = Utils()
       private let currentVC : UIViewController
       private let dialog = Dialog()
       private var flagImageSave = false
       private var imageAction : FlexAction? = nil
       private var width : Double!
       private var height : Double!
       private var imagePicker: UIImagePickerController!
       
       
       init(_ currentVC : UIViewController){
           self.currentVC = currentVC
       }
       
       //카메라 실행 모듈
       func cameraFunction() -> (FlexAction, Array<Any?>?) -> Void? {
           return { (action, arguments) -> Void in
               
               self.imageAction = action
               self.width = arguments?[0] as? Double
               self.height = arguments?[1] as? Double

               var returnStr : String?
               let cameraAuthorizationsStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
               
               switch cameraAuthorizationsStatus {
               case .authorized :
                   returnStr = AuthrizeStatus.authorized.rawValue
                   self.cameraPhotosAction(ModuleType.camera.rawValue)
               case .denied :
                   returnStr = AuthrizeStatus.denied.rawValue
                   self.util.setAuthAlertAction(currentVC : self.currentVC,  dialog: self.util.authDialog)
               case .notDetermined:
                   AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
                       if response {
                           self.cameraPhotosAction(ModuleType.camera.rawValue)
                       }else {
                           self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: [["확인", "basic"]] , type : "alert", animated : true, promiseAction : nil)
                           returnStr = AuthrizeStatus.denied.rawValue
                       }
                   }
               case .restricted:
                   returnStr = AuthrizeStatus.restricted.rawValue
               default:
                   returnStr = "default"
                   break
               }
                 if let printStr = returnStr {
                             print(printStr)
               }
           }
       }

}

extension CameraPhotos :  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Photos를 실행시키는 모듈
       func photosFunction() -> (FlexAction, Array<Any?>?) -> Void?  {
           return { (action, arguments) -> Void in
               
               self.imageAction = action
               self.width = arguments?[0] as? Double
               self.height = arguments?[1] as? Double
               
               let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
               var returnStr : String?
               switch photoAuthorizationStatus{
               case .authorized:
                   returnStr = AuthrizeStatus.authorized.rawValue
                   self.cameraPhotosAction(ModuleType.photos.rawValue)
               case .denied:
                   returnStr = AuthrizeStatus.denied.rawValue
                   self.util.setAuthAlertAction(currentVC : self.currentVC,  dialog: self.util.authDialog)
               case .notDetermined:
                   PHPhotoLibrary.requestAuthorization({(status) in
                       switch status {
                       case .authorized :
                           returnStr = AuthrizeStatus.authorized.rawValue
                           self.cameraPhotosAction(ModuleType.photos.rawValue)
                       case .denied :
                           self.dialog.makeDialog(self.currentVC, title : "알림", message : "해당 권한이 거부되었습니다." , btn: [["확인" , "basic"]] , type : "alert", animated : true, promiseAction: nil)
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
               if let printStr = returnStr {
                   print(printStr)
               }
           }
       }
       
       func cameraPhotosAction( _ type : String) -> Void {
           self.imagePicker = UIImagePickerController()
           imagePicker.delegate = self
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
                   }else {
                       self.dialog.makeDialog(self.currentVC, title : "경고", message : "카메라에 접근할 수 없습니다" , btn: [["destructive" , "확인"]] , type : "alert", animated : true, promiseAction: nil)
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
                       self.dialog.makeDialog(self.currentVC, title : "경고", message : "Photos에 접근할 수 없습니다" , btn: [["destructive" , "확인"]] , type : "alert", animated : true, promiseAction: nil)
                   }
                   break
               default:
                   break
               }
           }
       }
       
    // 사진 한장 선택
       @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           self.currentVC.dismiss( animated: true){
               let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
               if mediaType.isEqual(to: kUTTypeImage as NSString as String){
                   let captureImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                   let resizedImage = self.resizeImage(image: captureImage, targetSize: CGSize(width: self.width, height: self.height))
                   if self.flagImageSave {
                       UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
                   }
                   let imageData:NSData = resizedImage.jpegData(compressionQuality: 0.25)! as NSData
                   let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                   let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                   self.imageAction?.PromiseReturn(encodedString)
               }
           }
       }
       
       
       //사진 여러장 선택
       func MultiplePhotosFunction() -> (FlexAction, Array<Any?>?) -> Void?{
           return { (action, arguments) -> Void in
                self.imageAction = action
                self.width = arguments?[0] as? Double
                self.height = arguments?[1] as? Double
            
                var imageArray = [DKAsset]()
                var multiImageArray = [String]()

                DispatchQueue.main.async {
                    let multiPicker = DKImagePickerController()
                    multiPicker.maxSelectableCount = 10
                    multiPicker.showsCancelButton = true
                    multiPicker.allowsLandscape = false
                    multiPicker.assetType = .allPhotos
                    
                    self.currentVC.present(multiPicker, animated : true)
                   
                    multiPicker.didSelectAssets = { (assets : [DKAsset]) in
                        imageArray.append(contentsOf: assets)
                       
                        multiImageArray = imageArray.map {
                            let captureImage = self.getAsset(asset: $0.originalAsset.self!)
                            let imageData:NSData = captureImage.jpegData(compressionQuality: 0.25)! as NSData
                            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                            let encodedString = strBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
                       
                            return encodedString
                        }
                        self.imageAction!.PromiseReturn(multiImageArray)
                    }
                }
            }
        }
    
        //PHAsset -> UIImage 변환
        func getAsset(asset: PHAsset) -> UIImage {
        var image = UIImage()
            let imgManager = PHImageManager.default()
                       let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            imgManager.requestImage(for: asset, targetSize: CGSize(width: self.width, height: self.height), contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (img, _) in
                           image = img!
                       })
            return image
        }
       
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           self.currentVC.dismiss(animated: true) {self.imageAction?.PromiseReturn("Cancel")}
       }
       
       func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
           let size = image.size
           let widthRatio  = targetSize.width  / size.width
           let heightRatio = targetSize.height / size.height

           var newSize: CGSize
           if(widthRatio > heightRatio) {
               newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
           } else {
               newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
           }

           let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

           UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           return newImage!
       }
}
/*
    위치모듈
*/
class Location: NSObject{
    
    private let util = Utils()
    private var returnLocation = Dictionary<String,String?> ()
    private let currentVC : UIViewController
    private var locationManager = CLLocationManager()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func locationFunction() -> ((Array<Any?>?) -> Any?) {
        return { (arguments) -> Dictionary<String,Any?>  in
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways, .authorizedWhenInUse :
                self.getLocation()
                break
            case .denied, .restricted :
                self.util.setAuthAlertAction(currentVC : self.currentVC, dialog: self.util.authDialog)
                break
            case .notDetermined :
                self.returnLocation.removeAll()
                self.locationManager.requestWhenInUseAuthorization()
                break
            default :
                break
            }
            return self.returnLocation
        }
    }
    
    private func getLocation() -> Void {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        print ("getlocation")
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude
        let longtitude = coor?.longitude
        if let la = latitude , let lo = longtitude {
            returnLocation.updateValue(String(describing : la ), forKey: "latitude")
            returnLocation.updateValue(String(describing : lo ), forKey: "longtitude")
        }
     }
}

extension Location : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if(status == .authorizedAlways || status == .authorizedWhenInUse){
               locationManager.delegate = self
               print(AuthrizeStatus.authorized.rawValue)
           }
       }
}

/*
    알럿 모듈
*/
class Dialog {

    func dialogFunction(_ currentVC : UIViewController) -> (FlexAction, Array<Any?>?) -> Void {
        return { (action,  arguments) -> Void in
            let title = arguments?[0] as! String
            let message = arguments?[1] as! String
            let btn = arguments?[2] as! [[String]]
            let type = arguments?[3] as! String
            let animated = ((arguments?[4]) != nil) as Bool
            
            self.makeDialog(currentVC, title : title, message : message , btn: btn , type : type, animated : animated, promiseAction : action)
        }
    }
    
    func makeDialog(_ currentVC : UIViewController, title : String, message : String , btn : [[String]]?, type : String?, animated : Bool, promiseAction : FlexAction?){
        
        DispatchQueue.main.async {
            var dialog : UIAlertController
            var btnAction : UIAlertAction!
            if type == "alert" {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .alert)
                
                if let alertBtn = btn {
                
                    for i in 0 ..< alertBtn.count {
                            switch alertBtn[i][1] {
                            case "basic" :
                                btnAction = UIAlertAction(title : alertBtn[i][0], style: .default){ alertAction in
                                    if let mAction = promiseAction {
                                        mAction.PromiseReturn(alertBtn[i][0])
                                    }
                                }
                                break
                            case "cancel" :
                                btnAction = UIAlertAction(title : alertBtn[i][0], style: .cancel){ alertAction in
                                    if let mAction = promiseAction {
                                        mAction.PromiseReturn(alertBtn[i][0])
                                    }
                                }
                                break
                            case "destructive" :
                                btnAction = UIAlertAction(title : alertBtn[i][0], style: .destructive){ alertAction in
                                    if let mAction = promiseAction {
                                        mAction.PromiseReturn(alertBtn[i][0])
                                    }
                                }
                                break
                            default :
                                break
                            }
                        if let action = btnAction {
                            dialog.addAction(action)
                        }
                    }
                }
            }else {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .alert)
            }
            currentVC.present(dialog, animated: animated, completion: nil)
        }
    }
}

/*
    생체인증 모듈
*/
class BioAuth {
    var authDescriptions : String!
    
    func authFunction() -> (FlexAction, Array<Any?>?) -> Void {
    return { (action,  arguments) -> Void in
        let authContext = LAContext()
        
        var error : NSError?
        
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print ("Auth Disabled")
            action.PromiseReturn(AuthrizeStatus.disabled.rawValue)
            print(error as Any)
            return
        }
        
        switch authContext.biometryType {
        case .faceID:
            self.authDescriptions = "Face ID로 인증합니다."
            break
        case .touchID:
            self.authDescriptions = "지문 인식해주세용"
            break
        default:
            self.authDescriptions = "로그인하세용"
            break
        }
       
        authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: self.authDescriptions){ (success, error) in
                if success {
                    print("지문인식 성공")
                    action.PromiseReturn(AuthrizeStatus.authorized.rawValue)
                }
                else {
                    if let error = error {
                        print(error.localizedDescription)
                        print("에러발생")
                        action.PromiseReturn(AuthrizeStatus.error.rawValue)
                    }
                    action.PromiseReturn("cancel")
                }
            }
        }
    }
}

/*
    권한 / 루팅체킹 모듈
*/
class CheckRooting {
    
    func checkRootingFunction (_ currentVC : UIViewController) -> ((Array<Any?>?) -> Any?) {
        return{ (arguments) -> String in
            var returnStr : String = "Not Root Autority"
            DispatchQueue.main.async{
                if self.hasJailbreak() {
                    returnStr = "RootAuthority"
                    let dialog = UIAlertController(title: nil, message: "루트권한을 가진 디바이스에서는 실행할 수 없습니다. 앱이 종료됩니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default){
                        (action:UIAlertAction!) in
                        exit(0)
                    }
          
                    dialog.addAction(action)
                    currentVC.present(dialog, animated: true, completion: nil)
                }
            }
            return returnStr
        }
    }
    
    func hasJailbreak() -> Bool {
        
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }
        
        #if arch(i386) || arch(x86_64)
        return false
        #endif
        
        //file check
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            return true
        }
        
        //rootAutority check
        if canOpen(path: "/Applications/Cydia.app") ||
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            canOpen(path: "/bin/bash") ||
            canOpen(path: "/usr/sbin/sshd") ||
            canOpen(path: "/etc/apt") ||
            canOpen(path: "/usr/bin/ssh") {
            return true
        }
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
}

/*
    네트워크 확인 모듈
*/
class Reachability {

    var returnStr : String!
    
    func checkNetworkConnect(_ currentVC : UIViewController) -> ((Array<Any?>?) -> Any?) {
        return {(arguments) -> String in
            if self.isConnectedToNetwork() {
                self.returnStr = "Network is Connected"
            }else {
                let networkCheckAlert = UIAlertController(title: "Network Error", message : "앱을 종료합니다.", preferredStyle: UIAlertController.Style.alert)
                
                networkCheckAlert.addAction(UIAlertAction(title : "확인", style : .default){ (UIAlertAction) in
                    self.returnStr = "Network is Not Connected"
                    exit(0)
                })
                currentVC.present(networkCheckAlert, animated : true, completion: nil)
            }
            
            return self.returnStr
        }
    }
    
    func isConnectedToNetwork() -> Bool{
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let returnVal = (isReachable && !needsConnection)

        return returnVal
    }

}

/*
    QR코드스캔 모듈
*/
class CodeScan : NSObject {
    private var currentVC : UIViewController
    private var captureSession : AVCaptureSession?
    private var flexAction : FlexAction?
    private let qrCodeFrameView = UIView()
    private let view : UIView
    private var previewLayer : CALayer!
    
    init (_ viewController : UIViewController){
        self.currentVC = viewController
        self.view = viewController.view
    }
    
    func codeScanFunction() -> (FlexAction, Array<Any?>?) ->Void? {
        return { (action, argument) -> Void in
            self.flexAction = action
            if let captureSession = self.createCaptureSession(){
                self.captureSession = captureSession
                print ("codeScanFunction")
                DispatchQueue.main.async {
                    print ("DispatchQueue")
                    self.previewLayer = self.createPreviewLayer(withCaptureSession : captureSession)
                    
                    self.view.isUserInteractionEnabled = false
                    self.view.layer.addSublayer(self.previewLayer)
                    
                    self.qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    self.qrCodeFrameView.layer.borderWidth = 2
                    
                    self.view.addSubview(self.qrCodeFrameView)
                    self.view.bringSubviewToFront(self.qrCodeFrameView)
                    
                }
                self.requestCaptureSessionStartRunning()
             
            }
        }
    }

    
}

extension CodeScan : AVCaptureMetadataOutputObjectsDelegate{
    private func createCaptureSession() -> AVCaptureSession?{
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return nil}
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddInput(deviceInput){
                captureSession.addInput(deviceInput)
            }else {
                return nil
            }
            
            if captureSession.canAddOutput(metaDataOutput){
                captureSession.addOutput(metaDataOutput)
                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = self.metaObjectTypes()

            }else {
                return nil
            }
        }catch{
            return nil
        }
        return captureSession
    }
    
    func metaObjectTypes() -> [AVMetadataObject.ObjectType]{
        return [.qr,
                .code128,
                .code39,
                .code39Mod43,
                .code93,
                .ean8,
                .ean13,
                .interleaved2of5,
                .itf14,
                .pdf417,
                .upce
                ]
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer{
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
    
    func requestCaptureSessionStartRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if !captureSession.isRunning{
            captureSession.startRunning()
        }
    }
    
    func requestCaptureSessionStopRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.previewLayer.removeFromSuperlayer()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    public func metadataOutput(_ output : AVCaptureMetadataOutput,
                                     didOutput metadataObjects : [AVMetadataObject],
                                     from connection : AVCaptureConnection){
              self.scannerDelegate(output, didOutput: metadataObjects, from: connection)
              
          }
       
       func scannerDelegate (_ output : AVCaptureMetadataOutput,
                             didOutput metadataObjects: [AVMetadataObject],
                             from connection: AVCaptureConnection){
            if metadataObjects.count == 0 {
                print ("No QR Code is detected")
                  self.requestCaptureSessionStopRunning()
                return
            }
          
           if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                flexAction?.PromiseReturn(stringValue)
                self.requestCaptureSessionStopRunning()
           }
    }
}

/*
    NFC리딩 모듈
*/
#if canImport(CoreNFC)
class NFC : NSObject, NFCNDEFReaderSessionDelegate{
   
    private var nfcSession : NFCNDEFReaderSession!
    private var flexAction : FlexAction!
    private var nfcString : Array<String>!
    
    func nfcReadingFunction () -> (FlexAction, Array<Any?>?)-> Void? {
        return { (action, argument) -> Void in
            self.flexAction = action
            self.nfcSession = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
            self.nfcSession.begin()
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
           for message in messages {
               for record in message.records {
                   if let string = String(data: record.payload, encoding: .ascii) {
                    self.nfcString.append(string)
                       print(string)
                   }
               }
           }
        flexAction.PromiseReturn(self.nfcString)
       }
       

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC Reading Error : ", error.localizedDescription)
    }
}
#endif

/*
 메세지 모듈 (송신)
 */

class Message : NSObject, MFMessageComposeViewControllerDelegate {
    
    var returnMsg : String!
    var flexAction : FlexAction!
    
    func sendMessge (_ currentVC : UIViewController)  -> (FlexAction, Array<Any?>?) -> Void? {
        return { (action, argument) -> Void in
            let number = argument?[0] as! String
            let message = argument?[1] as! String
            self.flexAction = action
            DispatchQueue.main.async {
                let messageComposer = MFMessageComposeViewController()
                messageComposer.messageComposeDelegate = self
                if MFMessageComposeViewController.canSendText(){
                    messageComposer.recipients = [number]
                    messageComposer.body = message
                    currentVC.present(messageComposer, animated: true, completion: nil)
                }
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.sent:
            returnMsg = "Complete Sending Msg"
            break
        case MessageComposeResult.cancelled:
            returnMsg = "Sending msg cancelled"
            break
        case MessageComposeResult.failed:
            returnMsg = "fail to send Msg"
            break
        default:
            break
        }
        self.flexAction.PromiseReturn(returnMsg)
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

/*
 노티피케이션
 */
class Notification {
    
    let currentVC : UIViewController
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func notifiFunction () -> ( Array<Any?>?) -> Any?{
        return {(arguments) -> String in
            
            let content = UNMutableNotificationContent()
            content.title = arguments?[0] as! String
            content.subtitle = arguments?[1] as! String
            content.body = arguments?[2] as! String
            content.badge = NSNumber(value: arguments?[3] as! Int)
            
            let identifier = arguments?[4] as! String
            let isRepeat = arguments?[5] as! Bool

            let sec = arguments?[6] as! Double
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sec , repeats:isRepeat)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            return "Notification Activate!"
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        self.currentVC.present(self.currentVC, animated: true, completion: nil)
    }
}

class File : NSObject, UIDocumentPickerDelegate{
    
    let currentVC : UIViewController
    var flexAction : FlexAction!
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func importFile () -> (FlexAction, Array<Any?>?) -> Void? {
        return { (action, argument) -> Void in
            self.flexAction = action
            
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages"
                                                                                                               , "com.apple.iwork.numbers.numbers"
                                                                                                               , "com.apple.iwork.keynote.key"
                                                                                                               , "public.image"
                                                                                                               , "com.apple.application"
                                                                                                               , "public.item"
                                                                                                               , "public.data"
                                                                                                               , "public.content"
                                                                                                               , "public.audiovisual-content"
                                                                                                               , "public.movie"
                                                                                                               , "public.audiovisual-content"
                                                                                                               , "public.video"
                                                                                                               , "public.audio"
                                                                                                               , "public.text"
                                                                                                               , "public.data"
                                                                                                               , "public.zip-archive"
                                                                                                               , "com.pkware.zip-archive"
                                                                                                               , "public.composite-content"
                                                                                                               , "public.text"], in: UIDocumentPickerMode.import)
            DispatchQueue.main.async {
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.currentVC.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let newUrls = urls.compactMap { (url: URL) -> URL? in
            // Create file URL to temporary folder
            var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            // Apend filename (name+extension) to URL
            tempURL.appendPathComponent(url.lastPathComponent)
            do {
                // If file with same name exists remove it (replace file with new one)
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(atPath: tempURL.path)
                }
                // Move file from app_id-Inbox to tmp/filename
                try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)
                return tempURL
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }

        var returnDic = Dictionary<String,String>()
        returnDic.updateValue(newUrls[0].absoluteString, forKey: "URLString")
        returnDic.updateValue(newUrls[0].lastPathComponent, forKey: "Name")
        print(returnDic)
        flexAction.PromiseReturn(returnDic)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("close")
        controller.dismiss(animated: true, completion: nil)
    }
}

/*
 음성녹음
 */
/*
class VoiceRecord : NSObject{
    
    var mWebView : FlexWebView!
    
    var audioPlayer : AVAudioPlayer!
    var audioFile : URL!
    var progressTimer : Timer!
    var flexAction : FlexAction!
    
    var isRecorderMode : Bool
    var audioRecorder : AVAudioRecorder!
    var endTime : String!
    var currentTime : String!
    var volume : Float!
    var fileName : String!
    var mode : String!
    var recordTime : String!
   // let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)

    
    init(_ mWebView : FlexWebView, _ isRecordMode : Bool){
        self.isRecorderMode = isRecordMode
        self.mWebView = mWebView
    }
    
    func voiceRecordFunction () -> (FlexAction, Array<Any?>?) -> Void? {
        return { (action, argument) -> Void in
            print("voidRecordFunction")
            
            self.flexAction = action
            self.fileName = argument?[0] as? String
            self.mode = argument?[1] as? String
        
            self.selectAudioFile()
            
            if self.mode == "Play" {
                if !(self.isRecorderMode) {
                    print("!!isRecorderMode  Play")
                    self.volume = argument?[2] as? Float
                    self.recordTime = self.convertNSTimeInterval2String(0)
                    
                    self.initPlay()
                }else {
                    print("isRecorderMode  Play")
                    if let status = self.audioPlayer{
                        status.stop()
                        status.currentTime = 0
                        self.recordTime = self.convertNSTimeInterval2String(0)
                    }
                    self.initRecord()
                    self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)

                }
            }else if self.mode == "Stop"{
                print("!!isRecorderMode  Stop")
                if !(self.isRecorderMode) {
                    self.btnStopAudio()
                } else {
                    print("isRecorderMode  Stop")
                    self.btnStopRecord()
                }
            }else if self.mode == "Pause" {
                if !(self.isRecorderMode) {
                    print("!!isRecorderMode  Pause")
                    self.btnPauseAudio()
                }else {
                    print("isRecorderMode  Pause")
                    self.btnPauseRecord()
                }
            }
        }
    }
    
    @objc func timerCallback(){
        mWebView.evalFlexFunc("Timer", sendData: currentTime!)
    }

    func selectAudioFile() -> Void {
        if !(isRecorderMode) {
            audioFile = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        }else{//녹음모드
            //녹음모드일 때는 새 파일인 recordFile.m4a가 생성 된다.
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioFile = documentDirectory.appendingPathComponent("\(fileName!).m4a")
        }
    }

    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d",min,sec)
        
        return strTime
    }

    @objc func updatePlayTime() -> Void {
        currentTime = convertNSTimeInterval2String(audioPlayer.currentTime)
        print(currentTime!)
    }

    func btnPauseAudio() {
        audioPlayer.pause()
        flexAction.PromiseReturn("Pause Playing")
    }

    func btnStopAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        currentTime = convertNSTimeInterval2String(0)
        progressTimer.invalidate()
        flexAction.PromiseReturn("Stop Playing")
    }
    
    func btnPauseRecord() {
        audioRecorder.pause()
        flexAction.PromiseReturn("Pause Recording")
    }
    
    func btnStopRecord() {
        audioRecorder.stop()
        flexAction.PromiseReturn("Stop Recording \(String(describing: currentTime))")
        recordTime = convertNSTimeInterval2String(0)
        progressTimer.invalidate()
    }
}

extension VoiceRecord : AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    //녹음을 위한 초기화 함수 : 음질은 최대, 비트율 320kbps, 오디오 채널은 2, 샘플율은 44,100hz
    func initRecord() -> Void {
        let recordSettings = [
            AVFormatIDKey : NSNumber(value : kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0] as [String : Any]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        } catch let error as NSError {
            print("error-initRecord:\(error)")
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        if let volume = volume {
            audioPlayer.volume = volume
        }
        endTime = convertNSTimeInterval2String(0)
        currentTime = convertNSTimeInterval2String(0)
        
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let error as NSError {
            print("error-setcategory : \(error)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("error-setActive : \(error)")
        }
    }

    func initPlay(){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
        } catch let error as NSError { //오류타입
            print("error-initplay : 해당 오디오파일이 존재하지 않습니다. \(error) ")
        }

        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        if let volume = volume {
           audioPlayer.volume = volume
        }
        endTime = convertNSTimeInterval2String(audioPlayer.duration)
        currentTime = convertNSTimeInterval2String(0)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate()
        flexAction.PromiseReturn("Finished Playing")
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            flexAction.PromiseReturn("Finished Recording")
    }

}
*/
