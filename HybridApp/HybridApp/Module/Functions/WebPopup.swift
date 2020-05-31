//
//  WebPopup.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import WebKit
import FlexHybridApp

class WebPopup : NSObject, WKNavigationDelegate, WKUIDelegate{
    
    private var currentVC : UIViewController!
    private var createWebView: WKWebView!
    private var tempView : UIView!
    private var mWebview : FlexWebView!
    private var flexAction : FlexAction!
    private  let db = DataBase()
    
    func popupFunction(_ component : FlexComponent) -> (FlexAction, Array<Any?>?) -> Void?
    {
        return { (action, argument) -> Void in
            DispatchQueue.main.async {

                self.currentVC  = component.parentViewController!
                self.mWebview = component.FlexWebView!
                self.mWebview.uiDelegate = self
                self.flexAction = action
                
                let urlName = argument?[0] as! String
                let type = argument?[1] as! String
                
                var x = argument?[2]
                var y = argument?[3]
                
                if x == nil{ x = 1.0 }
                if y == nil{ y = 1.0 }
                
                self.tempView = UIView(frame: self.currentVC.view.bounds)
                self.tempView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.currentVC.view.addSubview(self.tempView!)
                
                let sizeX = self.tempView!.frame.width * (x as! CGFloat)
                let sizeY = self.tempView!.frame.height * (y as! CGFloat)
                
                let startX = self.tempView!.frame.width / 2 - sizeX / 2
                let startY = self.tempView!.frame.height
            
                self.createWebView = WKWebView(frame: CGRect(x: startX, y: startY , width: sizeX , height: sizeY), configuration: WKWebViewConfiguration())
                self.createWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.createWebView?.uiDelegate = self
                self.tempView?.addSubview(self.createWebView!)
                
                self.createWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: urlName, ofType: type, inDirectory: "Script")!)))

                self.db.openDataBase()
                self.db.createVisitURL(url: self.createWebView.url!, date: Date())

                WKWebView.animate(withDuration: 0.1, animations: {()->Void in
                    let height = self.createWebView!.frame.height
                    let width = self.createWebView!.frame.width
                    let yPos = self.currentVC.view.frame.height / 2 - height / 2
                    let xPos = self.currentVC.view.frame.width / 2 - width / 2
                    self.createWebView!.frame = CGRect(x: xPos, y: yPos,
                                                       width: width,
                                                       height: height)
                })
                self.flexAction.PromiseReturn("Popup Open")
            }
       }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == createWebView {
            tempView?.removeFromSuperview()
            createWebView?.removeFromSuperview()
            createWebView = nil
            tempView = nil
            
            db.createVisitURL(url: mWebview.url!, date: Date())
        }
    }
}
