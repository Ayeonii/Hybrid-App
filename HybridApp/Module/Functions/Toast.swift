//
//  Toast.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/02.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

class Toast: NSObject {
    
    private let currentVC : UIViewController
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    lazy var toast = FlexClosure.void { (argument) in
        let message = argument[0].asString() ?? ""
        let isShort = argument[1].asBool() ?? true
        DispatchQueue.main.async {
            ToastView.show(self.currentVC.view, msg: message, isShort: isShort)
        }
    }
    
}

class ToastView: UILabel {
    
    static func show(_ baseView: UIView, msg: String, isShort: Bool) {
        if isShort {
            show(baseView, msg: msg, duration: 2)
        } else {
            show(baseView, msg: msg, duration: 3.5)
        }
    }
    
    static func show(_ baseView: UIView, msg: String, duration: Double) {
        let overlayView = UIView()
        let lbl = UILabel()
        
        overlayView.frame = CGRect(x: 0, y: 0, width: baseView.frame.width - 60  , height: 50)
        overlayView.center = CGPoint(x: baseView.bounds.width / 2, y: baseView.bounds.height - 100)
        overlayView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.alpha = 0
        
        lbl.frame = CGRect(x: 0, y: 0, width: overlayView.frame.width, height: 50)
        lbl.numberOfLines = 0
        lbl.textColor = UIColor.white
        lbl.center = overlayView.center
        lbl.text = msg
        lbl.textAlignment = .center
        lbl.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(lbl)
        
        baseView.addSubview(overlayView)
                
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 1
        })
        { (_) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration ){
                UIView.animate(withDuration: 0.3, animations: {
                    overlayView.alpha = 0
                }) { (_) in
                    lbl.removeFromSuperview()
                    overlayView.removeFromSuperview()
                }
            }
        }
    }

}
