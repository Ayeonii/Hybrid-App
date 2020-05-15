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

enum ModuleType : String{
    case camera = "Camera"
    case photos = "Photos"
}

enum AuthrizeStatus : String {
    case authorized = "Access Authorized."
    case denied = "Access Denied"
    case restricted = "Access Restricted"
}





class Utils: NSObject {
    
    let deniedDialog = UIAlertController (title : "알림", message : "권한을 거부하였습니다.", preferredStyle: .alert)
    let authDialog = UIAlertController (title : "권한요청", message : "권한을 허용해야만 해당 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
    var flagImageSave = true
    
    //Camera
    func CameraFunction(_ currentVC : UIViewController) -> String? {
        var returnStr : String?
        let cameraAuthorizationsStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch cameraAuthorizationsStatus {
        case .authorized :
            returnStr = AuthrizeStatus.authorized.rawValue
            self.CameraPhotosAction(currentVC, ModuleType.camera.rawValue)
        case .denied :
            returnStr = AuthrizeStatus.denied.rawValue
            self.setAuthAlertAction(currentVC, dialog: self.authDialog)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
                if response {
                    self.CameraPhotosAction(currentVC, ModuleType.camera.rawValue)
                }else {
                    var confirmAction : Array <UIAlertAction> = []
                    confirmAction.append(UIAlertAction(title : "확인", style: .destructive, handler: nil))
                    self.AlertDialog(currentVC, self.deniedDialog, animated: true, action: confirmAction, completion: nil)
                }
            }
        case .restricted:
            returnStr = AuthrizeStatus.restricted.rawValue
        default:
            break
        }
        return returnStr
    }
    
    //Photos
    func PhotosFunction(_ currentVC : UIViewController) -> String? {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        var returnStr : String?
        
        switch photoAuthorizationStatus{
        case .authorized:
            returnStr = AuthrizeStatus.authorized.rawValue
            self.CameraPhotosAction(currentVC, ModuleType.photos.rawValue)
        case .denied:
            returnStr = AuthrizeStatus.denied.rawValue
            self.setAuthAlertAction(currentVC, dialog: self.authDialog)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized :
                    returnStr = AuthrizeStatus.authorized.rawValue
                    self.CameraPhotosAction(currentVC, ModuleType.photos.rawValue)
                case .denied :
                    var confirmAction : Array <UIAlertAction> = []
                    confirmAction.append(UIAlertAction(title : "확인", style: .destructive, handler: nil))
                    self.AlertDialog(currentVC, self.deniedDialog, animated: true, action: confirmAction, completion: nil)
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
    
    //Dialog
    func setAuthAlertAction(_ currentVC : UIViewController, dialog : UIAlertController){
        var actions : Array<UIAlertAction>? = []
        
        let getAuthBtnAction = UIAlertAction(title : "설정", style: .default) {(UIAlertAction) in
            if let appSettings = URL(string : UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options : [:], completionHandler: nil)
            }
        }
        let cancelBtnAction = UIAlertAction(title : "취소", style: .destructive, handler: nil)
        
        actions?.append(getAuthBtnAction)
        actions?.append(cancelBtnAction)
        
        self.AlertDialog(currentVC, dialog, animated: true,  action : actions, completion: nil)
    }
    
    //Alert
    func AlertDialog (_ currentVC : UIViewController , _ dialog: UIAlertController, animated: Bool,  action : Array<UIAlertAction>?, completion: (() -> Void)? = nil){
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
    
    func DialogAction(_ currentVC : UIViewController , ){
        
    }
    
}

extension Utils : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func CameraPhotosAction(_ currentVC : UIViewController, _ type : String) -> Void {

        DispatchQueue.main.async {
            switch type {
            case "Camera":
                let imagePicker: UIImagePickerController! = UIImagePickerController()
                
                if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                    self.flagImageSave = false
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    imagePicker.allowsEditing = false

                    currentVC.present(imagePicker, animated: true, completion: nil)
                }else {
                    let cameraAvailDialog = UIAlertController (title : "경고", message : "카메라를 사용할 수 없습니다.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title : "확인", style: .destructive, handler: nil)
                    cameraAvailDialog.addAction(confirmAction)
                    currentVC.present(cameraAvailDialog, animated: true, completion: nil)
                }
                
            case "Photos":
                let imagePicker: UIImagePickerController! = UIImagePickerController()
                
                if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                    self.flagImageSave = false
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    imagePicker.allowsEditing = true
                    
                    currentVC.present(imagePicker, animated: true, completion: nil)
                }
                
            default:
                return
            }
        }
    }
    
}
