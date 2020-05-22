//
//  Utils.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

import Photos
import MobileCoreServices

import CoreLocation

import LocalAuthentication

import AVFoundation    //Network / QR 코드
import SystemConfiguration

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
class CameraPhotos : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let viewController = ViewController()
    private let util = Utils()
    private let currentVC : UIViewController
    private let dialog = Dialog()
    private var flagImageSave = false
    private var imageAction : FlexAction? = nil
    private var width : Double!
    private var height : Double!
    let imagePicker: UIImagePickerController = UIImagePickerController()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
        super.init()
        imagePicker.delegate = self
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
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "권한을 거부하였습니다." , btn: [["basic" , "확인"]] , type : "alert", animated : true, promiseAction : nil)
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
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                    case .authorized :
                        returnStr = AuthrizeStatus.authorized.rawValue
                        self.cameraPhotosAction(ModuleType.photos.rawValue)
                    case .denied :
                        self.dialog.makeDialog(self.currentVC, title : "알림", message : "권한을 거부하였습니다." , btn: [["basic" , "확인"]] , type : "alert", animated : true, promiseAction: nil)
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.currentVC.dismiss(animated: true) {self.imageAction?.PromiseReturn("cancelled")}
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
class Location: NSObject, CLLocationManagerDelegate {
    
    private let util = Utils()
    private var returnLocation = Dictionary<String,String?> ()
    private let currentVC : UIViewController
    private var locationManager = CLLocationManager()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func locationFunction() -> ((Array<Any?>?) -> Any?) {
        
        locationManager.delegate = self

        return { (arguments) -> Dictionary<String,Any?>  in
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways, .authorizedWhenInUse :
                print("locationFunction : authori")
                self.getLocation()
                break
            case .denied, .restricted :
                print("locationFunction : denied")
                self.util.setAuthAlertAction(currentVC : self.currentVC, dialog: self.util.authDialog)
                break
            case .notDetermined :
                self.returnLocation.removeAll()
                print("locationFunction : notDetermined")
                self.locationManager.requestWhenInUseAuthorization()
                break
            default :
                print("locationFunction : default")
                break
            }
            return self.returnLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedAlways || status == .authorizedWhenInUse){
            locationManager.delegate = self
            print(AuthrizeStatus.authorized.rawValue)
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
                if !self.hasJailbreak() {
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
class CodeScan : NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private var currentVC : UIViewController
    private var captureSession : AVCaptureSession?
    private var flexAction : FlexAction?
    private let qrCodeFrameView = UIView()
    private let view : UIView
    
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
                    let previewLayer = self.createPreviewLayer(withCaptureSession : captureSession)
                    self.view.layer.addSublayer(previewLayer)
                    
                    self.qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    self.qrCodeFrameView.layer.borderWidth = 2
                    
                    self.view.addSubview(self.qrCodeFrameView)
                    self.view.bringSubviewToFront(self.qrCodeFrameView)
                    
                }
                self.requestCaptureSessionStartRunning()
             
            }
        }
    }

    private func createCaptureSession() -> AVCaptureSession?{
        let captureSession = AVCaptureSession()
        print ("createCaptureSession")
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
                print ("createCaptureSession -> captureSession.canAddOutput")
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
        print ("createPreviewLayer")
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
    
    func requestCaptureSessionStartRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if !captureSession.isRunning{
            print ("requestCaptureSessionStartRunning")
            captureSession.startRunning()
        }
    }
    
    func requestCaptureSessionStopRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if captureSession.isRunning {
            print ("requestCaptureSessionStopRunning")
            captureSession.stopRunning()
        }
    }
    
    public func metadataOutput(_ output : AVCaptureMetadataOutput,
                                     didOutput metadataObjects : [AVMetadataObject],
                                     from connection : AVCaptureConnection){
        print ("metadataOutput")
              self.scannerDelegate(output, didOutput: metadataObjects, from: connection)
              
          }
       
       func scannerDelegate (_ output : AVCaptureMetadataOutput,
                             didOutput metadataObjects: [AVMetadataObject],
                             from connection: AVCaptureConnection){
        print ("scannerDelegate")
            if metadataObjects.count == 0 {
                print ("No QR Code is detected")
                  self.requestCaptureSessionStopRunning()
                return
            }
          
           if let metadataObject = metadataObjects.first {
             print ("scannerDelegate -> metadataObject = metadataObjects.first")
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                flexAction?.PromiseReturn(stringValue)
                self.requestCaptureSessionStopRunning()
           }
      
    
    }
}

