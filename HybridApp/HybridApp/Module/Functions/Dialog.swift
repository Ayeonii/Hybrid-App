//
//  Dialog.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

/*
 알럿 모듈
 */
class Dialog {
    
    let util = Utils()
    
    func dialogFunction(_ currentVC : UIViewController) -> (FlexAction, Array<Any?>) -> Void {
        return { (action,  arguments) -> Void in
            
            self.util.setUserHistory(forKey: "DialogBtn")
            let title = arguments[0] as! String
            let message = arguments[1] as! String
            let btn = arguments[2] as! Dictionary<String,String>
            let type = arguments[3] as! Bool
            let animated = ((arguments[4]) != nil) as Bool
            
            self.makeDialog(currentVC, title : title, message : message , btn: btn , type : type, animated : animated, promiseAction : action)
        }
    }
    
    func makeDialog(_ currentVC : UIViewController, title : String, message : String , btn : Dictionary<String?,String?>, type : Bool?, animated : Bool, promiseAction : FlexAction?){

        DispatchQueue.main.async {
            var dialog : UIAlertController
            var btnAction : UIAlertAction!
            
    
            if !(type!), UIDevice.current.userInterfaceIdiom != .pad {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .actionSheet)
            } else {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .alert)
            }
            
            let basic = btn["basic"]
            let destructive = btn["destructive"]
            let cancel = btn["cancel"]
            
            if let basicName = basic {
                btnAction = UIAlertAction(title : basicName, style: .default){ alertAction in
                    promiseAction?.PromiseReturn(basicName)
                }
                dialog.addAction(btnAction)
            }
            
            if let destructiveName = destructive {
                btnAction = UIAlertAction(title : destructiveName, style: .destructive){ alertAction in
                    promiseAction?.PromiseReturn(destructiveName)
                }
                dialog.addAction(btnAction)
            }
            
            if let cancelName = cancel {
                btnAction = UIAlertAction(title : cancelName, style: .cancel){ alertAction in
                    promiseAction?.PromiseReturn(cancelName)
                }
                dialog.addAction(btnAction)
            }
            currentVC.present(dialog, animated: animated, completion: nil)
        }
    }
}
