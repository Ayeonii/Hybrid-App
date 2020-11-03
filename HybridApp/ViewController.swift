//
//  ViewController.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import WebKit
import FlexHybridApp
import SQLite3

class ViewController: UIViewController {
    
    var mWebView: FlexWebView!
    var component = FlexComponent()
    let urlObserver = URLObserver()
    var indicator : LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = ListeningObserver(self.urlObserver)
        
        mWebView = FlexWebView(frame: self.view.frame, component: component)

        component.setAction("Location", Location(self).location)
         
        component.setAction("RootingCheck", CheckRooting(self).checkRooting)
        
        component.boolInterface("Notification", Notification(self).notifiFunction)
        
        component.stringInterface("LocalRepository", User().userDefault)
        
        component.stringInterface("UniqueAppID") { _ in return UserDefaults.standard.string(forKey: Key.AppID) ?? "null" }
        
        component.voidInterface("Toast", Toast(self).toast)
        
        component.stringInterface("UniqueDeviceID", KeyChain().keyChainInit)
        
        component.voidInterface("WebPopup", WebPopup(component).popup)
        
        component.setAction("CameraByDeviceRatio", CameraPhotos(self).camera)
        
        component.setAction("CameraByRatio", CameraPhotos(self).camera)
             
        component.setAction("PhotoByDeviceRatio", CameraPhotos(self).photos)
        
        component.setAction("PhotoByRatio", CameraPhotos(self).photos)
        
        component.setAction("MultiPhotoByDeviceRatio", CameraPhotos(self).multiplePhotos)
        
        component.setAction("MultiPhotoByRatio", CameraPhotos(self).multiplePhotos)
    
        component.setAction("Dialog", Dialog(self).dialog)
        
        component.setAction("Authentication", BioAuth().auth)
        
        component.setAction("Network", CheckNetwork(self).checkNetwork)
        
        component.setAction("QRCodeScan", QRCodeScan(self).codeScan)
        
        component.setAction("SendSMS", Message(self).sendMessage)
        
        component.setAction("FileDownload", FileDownload(component).startFileDownload)
                
        #if canImport(CoreNFC)
        component.setAction("NFCReading", NFC(self).nfcReading)
        #endif

        component.setBaseUrl(Conf.BaseUrl)
        
        
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        mWebView.scrollView.bounces = false
        view.addSubview(mWebView)
        
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "Demo")!)))

        urlObserver.url = mWebView.url!
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        else if #available(iOS 11.0, *) {
            view.backgroundColor = UIColor.white
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            view.backgroundColor = UIColor.white
            mWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        indicator.showActivityIndicator(text: Msg.Loading, nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation : WKNavigation!){
        indicator.stopActivityIndicator()
        
    }
    
    
}

