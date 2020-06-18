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
        
    func dialogFunction(_ currentVC : UIViewController) -> (FlexAction, Array<Any?>) -> Void {
        return { (action,  arguments) -> Void in
            
            Utils.setUserHistory(forKey: "DialogBtn")
            let title = arguments[0] as! String
            let message = arguments[1] as! String
            let btn = arguments[2] as! Dictionary<String,String>
            let type = arguments[3] as! Bool
            let animated = ((arguments[4]) != nil) as Bool
            
            self.makeDialog(currentVC, title : title, message : message , btn: btn , type : type, animated : animated, promiseAction : action)
        }
    }
    
    func makeDialog(_ currentVC : UIViewController, title : String, message : String , btn : Dictionary<String,String>, type : Bool?, animated : Bool, promiseAction : FlexAction?){
        DispatchQueue.main.async {
            var dialog : UIAlertController
            var btnAction : UIAlertAction!
            
    
            if !(type!), UIDevice.current.userInterfaceIdiom != .pad {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .actionSheet)
            } else {
                dialog = UIAlertController (title : title, message : message, preferredStyle: .alert)
            }
            
            if let basic = btn["basic"] {
                btnAction = UIAlertAction(title : basic, style: .default)
                { alertAction in
                    promiseAction?.promiseReturn(basic)
                }
                dialog.addAction(btnAction)
            }
            
            if let destructive = btn["destructive"] {
                btnAction = UIAlertAction(title : destructive, style: .destructive){ alertAction in
                    promiseAction?.promiseReturn(destructive)
                }
                dialog.addAction(btnAction)
            }

            if let cancel = btn["cancel"] {
                btnAction = UIAlertAction(title : cancel, style: .cancel){ alertAction in
                    promiseAction?.promiseReturn(cancel)
                }
                dialog.addAction(btnAction)
            }
            
            if dialog.actions.count == 0 {
                promiseAction?.resolveVoid()
            }
            
            currentVC.present(dialog, animated: animated, completion: nil)
        }
    }
}
