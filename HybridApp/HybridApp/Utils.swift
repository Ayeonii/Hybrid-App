//
//  Utils.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import Photos

class Utils: NSObject {
    
    let dialog = UIAlertController (title : "주의", message : "일부 기능이 동작하지 않습니다. [설정] 에서 허용할 수 있습니다. ", preferredStyle: .alert)
    var flagImageSave = true
    
    func CameraPhotosAction(_ currentVC : UIViewController, _ type : String)-> Void {
        let imagePicker: UIImagePickerController! = UIImagePickerController()
        
        
        switch type{
        case "Camera":
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
              if response {
                  print ("Camera Access Authorized.")
                    if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                        self.flagImageSave = false
                        imagePicker.delegate = self
                        imagePicker.sourceType = .camera
                        imagePicker.allowsEditing = false
                        currentVC.present(imagePicker, animated: true, completion: nil)
                    }
              } else {
                currentVC.present(self.dialog, animated: true, completion: nil)
              }
            }
            break
        case "Photos" :
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch photoAuthorizationStatus {
            case .authorized:
                print ("Photos Access Authorized.")
                
            case .denied:
                print ("Photos Access Denied.")
                currentVC.present(self.dialog, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                    case .authorized :
                        print ("Photos Access Authorized.")
                        DispatchQueue.main.async {
                   
                            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                                self.flagImageSave = false
                                imagePicker.delegate = self
                                imagePicker.sourceType = .photoLibrary
                                imagePicker.allowsEditing = true
                                
                                currentVC.present(imagePicker, animated: true, completion: nil)
                            }
                        }
                    case .denied :
                        print ("Photos Aceess Denied.")
                    default:
                        break
                    }
                })
            case .restricted:
                print("Photos Access Restricted.")
            default:
                return
            }
            break
        default:
                return
        }
    }
}

extension Utils : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
