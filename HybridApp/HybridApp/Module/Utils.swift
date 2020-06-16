//
//  Utils.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
import Foundation
import CryptoSwift

enum AuthrizeStatus : String {
    case authorized = "Access Authorized."
    case denied = "Access Denied"
    case restricted = "Access Restricted"
    case disabled = "Access disabled"
    case error = "Error"
}

enum PathString : String {
    case codSignature = "/_CodeSignature"
    case codeResources = "CodeResources"
    case excutableFile = "/HybridApp"
    case dataOff = "dataoff"
    case dataSize = "datasize"
    case nonAuth = "비정상적인 접근입니다. 앱을 종료합니다."
}


/*
  모듈공통사용기능
 */
class Utils: NSObject {
    
    let authDialog = UIAlertController (title : "권한요청", message : "권한을 허용해야만 해당 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
    let userDefault = UserDefaults.standard
    var history = Array<Any?>()
    
    func setUserHistory(forKey : String){
        
        if let result = getUserHistory(forKey: forKey) {
            self.history = result
            self.history.append(Date())
        } else {
            self.history.append(Date())
        }

        self.userDefault.set(self.history,forKey: forKey)

    }
    
    func getUserHistory(forKey : String) -> Array<Any?>? {
        return self.userDefault.array(forKey: forKey)
    }
    
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
    
    //hasing
    func stringHash(targetString : String) -> String {
        return targetString.sha256()
    }

}



