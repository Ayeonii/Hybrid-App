//
//  Utils.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import CoreLocation


enum AuthrizeStatus : String {
    case authorized = "Access Authorized."
    case denied = "Access Denied"
    case restricted = "Access Restricted"
}


/*공통 사용 모듈*/
class Utils: NSObject {

    let authDialog = UIAlertController (title : "권한요청", message : "권한을 허용해야만 해당 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
    let deniedDialog = UIAlertController (title : "알림", message : "권한을 거부하였습니다.", preferredStyle: .alert)
    
    /*
    권한설정 버튼 다이얼로그
     */
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
    
    /*
     메인스레드에서 처리하기 위한 알럿 다이얼로그
     */
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
//카메라 및 앨범 관련 동작 수행
class CameraPhotos : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let viewController = ViewController()
    private let util = Utils()
    private var flagImageSave = true
    private let currentVC : UIViewController
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    /*
       카메라 실행 모듈
    */
    func cameraFunction() -> (Array<Any?>?) -> Any? {
        return { (arguments) -> String? in
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
                        DispatchQueue.main.async {
                            if self.util.deniedDialog.actions.isEmpty {
                                self.util.deniedDialog.addAction(UIAlertAction(title : "확인", style: .destructive, handler: nil))
                            }
                        }
                        self.util.alertDialog(currentVC : self.currentVC,
                                              dialog: self.util.deniedDialog, animated: true, action: nil, completion: nil)
                        returnStr = AuthrizeStatus.denied.rawValue
                    }
                }
            case .restricted:
                returnStr = AuthrizeStatus.restricted.rawValue
            default:
                break
            }
            return returnStr
        }
    }

       /*
        Photos를 실행시키는 모듈
        */
    
    func photosFunction() -> (Array<Any?>?) -> Any?  {
        return { (arguments) -> String? in
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
                        DispatchQueue.main.async {
                            if self.util.deniedDialog.actions.isEmpty {
                                self.util.deniedDialog.addAction(UIAlertAction(title : "확인", style: .destructive, handler: nil))
                            }
                        }
                        self.util.alertDialog(currentVC : self.currentVC,
                        dialog: self.util.deniedDialog, animated: true, action: nil, completion: nil)
                        returnStr = AuthrizeStatus.denied.rawValue
                    default:
                        break
                    }
                })
            case .restricted:
                returnStr = AuthrizeStatus.restricted.rawValue
            default :
                break
            }
            return returnStr
        }
    }
    
    
    private func cameraPhotosAction( _ type : String) -> Void {
        DispatchQueue.main.async {
            let imagePicker: UIImagePickerController! = UIImagePickerController()
            switch type {
            case "Camera":

                if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                    self.flagImageSave = false
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    imagePicker.allowsEditing = false

                    self.currentVC.present(imagePicker, animated: true, completion: nil)
                }else {
                    let cameraAvailDialog = UIAlertController (title : "경고", message : "카메라를 사용할 수 없습니다.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title : "확인", style: .destructive, handler: nil)
                    cameraAvailDialog.addAction(confirmAction)
                    self.currentVC.present(cameraAvailDialog, animated: true, completion: nil)
                }
                
            case "Photos":
                if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                    self.flagImageSave = false
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    imagePicker.allowsEditing = true
                    
                    self.currentVC.present(imagePicker, animated: true, completion: nil)
                }
                
            default:
                break
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    print(image)
                    print(info)
        }
        self.currentVC.dismiss(animated: true, completion: nil)
    }
}


//위치모듈
class Location: NSObject, CLLocationManagerDelegate {
    
    private let util = Utils()
    private var returnLocation = Dictionary<String,String?> ()
    private let currentVC : UIViewController
    private var locationManager = CLLocationManager()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func locationFunction() -> (Array<Any?>?) -> Any? {
        
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
        if status == .denied || status == .restricted {
            if self.util.deniedDialog.actions.isEmpty {
                self.util.deniedDialog.addAction(UIAlertAction(title : "확인", style: .destructive, handler: nil))
            }
        }else if(status == .authorizedAlways || status == .authorizedWhenInUse){
            self.getLocation()
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