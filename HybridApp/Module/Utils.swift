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

/*
  모듈공통사용기능
 */
class Utils: NSObject {
    
    static let authDialog = UIAlertController (title : "권한요청", message : "권한을 허용해야만 해당 기능을 사용하실 수 있습니다.", preferredStyle: .alert)
    static let userDefault = UserDefaults.standard
    
    static func setUserHistory(forKey : String){
        
        var history = Array<Any?>()
        
        if let result = getUserHistory(forKey: forKey) {
            history = result
            history.append(Date())
        } else {
            history.append(Date())
        }

        self.userDefault.set(history,forKey: forKey)

    }
    
    static func getUserHistory(forKey : String) -> Array<Any?>? {
        return self.userDefault.array(forKey: forKey)
    }
    
    //권한설정 버튼 다이얼로그
    static func setAuthAlertAction(currentVC : UIViewController, dialog : UIAlertController){
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
    static func alertDialog (currentVC : UIViewController, dialog: UIAlertController, animated: Bool, action : Array<UIAlertAction>?, completion: (() -> Void)? = nil){
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
    static func stringHash(targetString : String) -> String {
        return targetString.sha256()
    }
    
    static func genResult() -> [String:Any] {
        var result: [String:Any] = [:]
        result["auth"] = false
        result["data"] = nil
        result["msg"] = nil
        return result
    }
    
    static func checkSignature() {
        let obj = MachOSignature()
        guard let dic = obj.loadCodeSignature() else {
            forceCloseAlertDialog()
            return
        }
        guard let codeSign = dic[AnyHashable(J.J11)] as? String else {
            forceCloseAlertDialog()
            return
        }
        API.init().postCodeSign(codeSign: codeSign) { (result) -> Void in
            if !result {
               forceCloseAlertDialog()
            }
        }
   }
    
    // 강제 종료 alert dialog
    static func forceCloseAlertDialog() -> Void {
        let dialog = UIAlertController (title : C.C1, message : C.C2, preferredStyle: .alert)
        
        dialog.addAction(UIAlertAction(title: C.C3, style: .default, handler: {(action: UIAlertAction!) in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }))
        
        UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(dialog, animated: true, completion: nil)
    }
}
