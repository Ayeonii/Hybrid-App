//
//  Toast.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/02.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit

class Toast: NSObject {
    
    func toastFunction(_ currentVC : UIViewController) -> (Array<Any?>) -> Any? {
        return { (argument) -> Any? in
       
            let message = argument[0] as! String
            let isShort = argument[1] as! Bool
            var seconds : Double!
            
            if isShort {
                seconds = 2.0
            }else {
                seconds = 3.5
            }

            DispatchQueue.main.async {
                let alert = UIAlertController (title : nil, message: message, preferredStyle: .actionSheet)
            
                alert.view.backgroundColor = .black
                alert.view.alpha = 0.9
                alert.view.layer.cornerRadius = 15
            
                currentVC.present(alert, animated: true,completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds ){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            return nil
        }
        
    }

}