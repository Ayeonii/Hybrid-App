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

class WebPopup : NSObject, WKUIDelegate{
    
    private var createWebView: WKWebView!
    private var tempView : UIView!
    private var mWebview : FlexWebView!
    private let db = DataBase()
    private let urlObserver = URLObserver()
    private var dbsave: Observer!
    
    func popupFunction(_ component : FlexComponent) -> (Array<Any?>) -> Any?{
        return { (argument) -> Any? in
            DispatchQueue.main.async {
                self.dbsave = ListeningObserver(self.urlObserver)
                let currentVC  = component.parentViewController!
                self.mWebview = component.FlexWebView!
                
                let urlName = argument[0] as! String
                let type = argument[1] as! String
                
                var x = argument[2]
                var y = argument[3]
                
                if x == nil{ x = 1.0 }
                if y == nil{ y = 1.0 }
                
                self.tempView = UIView(frame: currentVC.view.bounds)
                self.tempView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                currentVC.view.addSubview(self.tempView!)
                
                let sizeX = self.tempView!.frame.width * (x as! CGFloat)
                let sizeY = self.tempView!.frame.height * (y as! CGFloat)
                
                let startX = self.tempView!.frame.width / 2 - sizeX / 2
                let startY = self.tempView!.frame.height
            
                self.createWebView = WKWebView(frame: CGRect(x: startX, y: startY , width: sizeX , height: sizeY), configuration: WKWebViewConfiguration())
                self.createWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.createWebView?.uiDelegate = self
                self.createWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: urlName, ofType: type, inDirectory: "Script")!)))
                self.tempView?.addSubview(self.createWebView!)
                
                self.urlObserver.url = self.createWebView.url!

                WKWebView.animate(withDuration: 0.1, animations: {()->Void in
                    let height = self.createWebView!.frame.height
                    let width = self.createWebView!.frame.width
                    let yPos = currentVC.view.frame.height / 2 - height / 2
                    let xPos = currentVC.view.frame.width / 2 - width / 2
                    self.createWebView!.frame = CGRect(x: xPos, y: yPos,
                                                       width: width,
                                                       height: height)
                })
            }
            return nil
       }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == createWebView {
            tempView?.removeFromSuperview()
            createWebView?.removeFromSuperview()
            createWebView = nil
            tempView = nil
         
            self.urlObserver.url = self.mWebview.url!
        }
    }
}
