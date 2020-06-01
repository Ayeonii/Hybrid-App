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
    
    func dialogFunction(_ currentVC : UIViewController) -> (FlexAction, Array<Any?>?) -> Void {
        return { (action,  arguments) -> Void in
            
            self.util.setUserHistory(forKey: "DialogBtn")
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
                                promiseAction?.PromiseReturn(alertBtn[i][0])
                            }
                            break
                        case "cancel" :
                            btnAction = UIAlertAction(title : alertBtn[i][0], style: .cancel){ alertAction in
                                promiseAction?.PromiseReturn(alertBtn[i][0])
                            }
                            break
                        case "destructive" :
                            btnAction = UIAlertAction(title : alertBtn[i][0], style: .destructive){ alertAction in
                                promiseAction?.PromiseReturn(alertBtn[i][0])
                            }
                            break
                        default :
                            promiseAction?.PromiseReturn(nil)
                            break
                        }
                        dialog.addAction(btnAction)
                    }
                }
            } else {
                promiseAction?.PromiseReturn(nil)
                dialog = UIAlertController (title : title, message : message, preferredStyle: .alert)
            }
            currentVC.present(dialog, animated: animated, completion: nil)
        }
    }
}
