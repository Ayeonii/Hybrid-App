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

        component.setInterface("Location", Location(self).locationFunction())
         
        component.setInterface("RootingCheck", CheckRooting().checkRootingFunction(self))
        
        component.setInterface ("Notification", Notification(self).notifiFunction())
        
        component.setInterface ("LocalRepository", User().userDefaultFunction())
        
        component.setInterface ("UniqueAppID"){_ in return UserDefaults.standard.string(forKey: "APP_UUID")}
        
        component.setInterface ("Toast",Toast().toastFunction(self))
        
        component.setInterface ("UniqueDeviceID", KeyChain().keyChainInit())
        
        component.setInterface ("WebPopup", WebPopup().popupFunction(component))
        
        component.setAction("CameraByDeviceRatio", CameraPhotos(self).cameraFunction())
        
        component.setAction("CameraByRatio", CameraPhotos(self).cameraFunction())
             
        component.setAction("PhotoByDeviceRatio", CameraPhotos(self).photosFunction())
        
        component.setAction("PhotoByRatio", CameraPhotos(self).photosFunction())
        
        component.setAction("MultiPhotoByDeviceRatio", CameraPhotos(self).MultiplePhotosFunction())
        
        component.setAction("MultiPhotoByRatio", CameraPhotos(self).MultiplePhotosFunction())
    
        component.setAction("Dialog", Dialog().dialogFunction(self))
        
        component.setAction("Authentication", BioAuth().authFunction())
        
        component.setAction("Network", CheckNetwork(self).checkNetworkConnect())
        
        component.setAction("QRCodeScan", QRCodeScan(self).codeScanFunction())
        
        component.setAction ("SendSMS", Message().sendMessge(self))
        
        component.setAction ("FileDownload", FileDownload().startFileDownload(component))
                
        #if canImport(CoreNFC)
        component.setAction ("NFCReading", NFC(self).nfcReadingFunction())
        #endif

        component.setBaseUrl("file://")
        
        mWebView = FlexWebView(frame: self.view.frame, component: component)
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        mWebView.scrollView.bounces = false
        view.addSubview(mWebView)
        
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "Script")!)))

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
}
