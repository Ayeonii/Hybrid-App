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

class WebPopup : NSObject, WKUIDelegate, WKNavigationDelegate{
    
    private var createWebView: WKWebView!
    private var tempView : UIView!
    private var mWebview : FlexWebView!
    private let db = DataBase()
    private let urlObserver = URLObserver()
    private var dbsave: Observer!
    private var currentVC : UIViewController!

    var indicator : LoadingView!
    
    
    func popupFunction(_ component : FlexComponent) -> (Array<Any?>) -> Any?{
        return { (argument) -> Any? in
            DispatchQueue.main.async {
                self.dbsave = ListeningObserver(self.urlObserver)
                self.currentVC  = component.parentViewController!
                self.mWebview = component.FlexWebView!
            
                let urlName = argument[0] as! String
            
                var x = argument[1]
                if x == nil{ x = 1.0 }
                
                self.tempView = UIView(frame: self.currentVC.view.bounds)
                self.tempView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.currentVC.view.addSubview(self.tempView!)
                
                let sizeX = self.tempView!.frame.width * (x as! CGFloat)
                let sizeY = self.tempView!.frame.height * (x as! CGFloat)
                
                let startX = self.tempView!.frame.width / 2 - sizeX / 2
                let startY = self.tempView!.frame.height
            
                self.createWebView = WKWebView(frame: CGRect(x: startX, y: startY, width: sizeX , height: sizeY), configuration: WKWebViewConfiguration())
                self.createWebView.clipsToBounds = true
                self.createWebView.layer.cornerRadius = 25
                self.createWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.createWebView.navigationDelegate = self
                self.createWebView.uiDelegate = self
                self.createWebView.load(URLRequest(url: URL(string : urlName)!))
                
                
                let cancelBtn = UIButton(frame: CGRect(x: startX, y:  0 , width: 35, height: 35))
                cancelBtn.center = CGPoint(x: self.tempView.frame.size.width / 2.0, y : (self.tempView.frame.size.height - self.createWebView.frame.size.height ) / 4.0)
                cancelBtn.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.3)
                cancelBtn.layer.cornerRadius = 0.5 * cancelBtn.bounds.size.width
                cancelBtn.setTitle("X", for: .normal)
                cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                cancelBtn.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .normal)
                cancelBtn.addTarget(self, action: #selector(self.webViewClose(sender:)), for: .touchUpInside)
                self.tempView.addSubview(cancelBtn)
                self.tempView.bringSubviewToFront(cancelBtn)
               
                self.tempView?.addSubview(self.createWebView!)
                print(urlName)
                self.urlObserver.url = self.createWebView.url!
 
                WKWebView.animate(withDuration: 0.1, animations: {()->Void in
                    let height = self.createWebView!.frame.height
                    let width = self.createWebView!.frame.width
                    let yPos = self.currentVC.view.frame.height / 2 - height / 2
                    let xPos = self.currentVC.view.frame.width / 2 - width / 2
                    self.createWebView!.frame = CGRect(x: xPos, y: yPos,
                                                       width: width,
                                                       height: height)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.indicator = LoadingView(self.currentVC.view)
                        self.indicator.showActivityIndicator(text: "로딩 중", nil)
                    })
                })
                

            }
            return nil
       }
    }
    
    @objc func webViewClose(sender : UIButton?) {
        tempView?.removeFromSuperview()
        createWebView?.removeFromSuperview()
        createWebView = nil
        tempView = nil
         
        self.urlObserver.url = self.mWebview.url!
    }

    func webView(_ webView: WKWebView, didFinish navigation : WKNavigation!){
        print("로딩끝")
        indicator.stopActivityIndicator()
    }
}
