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
    let userDefault = UserDefaults.standard
    var createWebView: WKWebView!
    var tempView : UIView!
    var currentURL : URL!
    let urlObserver = URLObserver()
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = ListeningObserver(self.urlObserver)
        
        component.setAction("Camera", CameraPhotos(self).cameraFunction())
             
        component.setAction("SinglePhoto", CameraPhotos(self).photosFunction())
        
        component.setAction("MultiplePhotos", CameraPhotos(self).MultiplePhotosFunction())
    
        component.setInterface("Location", Location(self).locationFunction())
        
        component.setAction("Dialog", Dialog().dialogFunction(self))
        
        component.setAction("BioAuthentication", BioAuth().authFunction())
        
        component.setInterface("RootingCheck", CheckRooting().checkRootingFunction(self))
        
        component.setAction("Network", CheckNetwork(self).checkNetworkConnect())
        
        component.setAction("QRCodeScan", QRCodeScan(self).codeScanFunction())
        
        #if canImport(CoreNFC)
        component.setAction ("NFCReading", NFC().nfcReadingFunction())
        #endif
        
        component.setAction ("SendMessage", Message().sendMessge(self))
        
        component.setInterface ("Notification", Notification(self).notifiFunction())
        
        component.setAction ("FileDownload", FileDownload(component).startFileDownload())
        
        component.setInterface ("UserDefault", User().userDefaultFunction())
        
        component.setInterface ("AppUUID"){_ in return self.userDefault.object(forKey: "APP_UUID")}
        
        component.setInterface ("DeviceUUID", KeyChain().keyChainInit())
        
        component.setInterface ("WebPopup", WebPopup().popupFunction(component))
        
        component.setBaseUrl("file://")
        
        mWebView = FlexWebView(frame: self.view.frame, component: component)
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        mWebView.scrollView.bounces = false
        view.addSubview(mWebView)
        
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "html", inDirectory: "Script")!)))

        urlObserver.url = mWebView.url!
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        }
        else if #available(iOS 11.0, *) {
            view.backgroundColor = UIColor.white
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        } else {
            view.backgroundColor = UIColor.white
            mWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
    }

}
