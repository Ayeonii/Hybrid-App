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
import KeychainAccess
import SQLite3

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler{
    
    var mWebView: FlexWebView!
    var component = FlexComponent()
    let userDefault = UserDefaults.standard
    var createWebView: WKWebView!
    var tempView : UIView!
    
    var currentURL : URL!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        component.setAction("Camera", CameraPhotos(self).cameraFunction())
             
        component.setAction("SinglePhoto", CameraPhotos(self).photosFunction())
        
        component.setAction("MultiplePhotos", CameraPhotos(self).MultiplePhotosFunction())
    
        component.setInterface("Location", Location(self).locationFunction())
        
        component.setAction("Dialog", Dialog().dialogFunction(self))
        
        component.setAction("BioAuthentication", BioAuth().authFunction())
        
        component.setInterface("RootingCheck", CheckRooting().checkRootingFunction(self))
        
        component.setAction("Network", CheckNetwork(self).checkNetworkConnect())
        
        component.setAction("QRCodeScan", CodeScan(self).codeScanFunction())
        
        #if canImport(CoreNFC)
        component.setAction ("NFCReading", NFC().nfcReadingFunction())
        #endif
        
        component.setAction ("SendMessage", Message().sendMessge(self))
        
        component.setInterface ("Notification", Notification(self).notifiFunction())
        
        component.setAction ("FileDownload", FileDownload(component).startFileDownload())
        
        component.setInterface ("UserDefault", User().userDefaultFunction())
        
        component.setInterface ("AppUUID"){_ in return self.userDefault.object(forKey: "APP_UUID")}
        
        component.setInterface ("DeviceUUID", self.keyChainInit())
        
        component.setAction ("WebPopup", WebPopup().popupFunction(component))
        
        component.setInterface("Record", openVoice().openVoiceScheme())
        
        component.setInterface("test2")
        { (arguments) -> Any? in
            self.mWebView.evalFlexFunc("help", sendData: "Help me Flex!")
            { (value) -> Void in
                // Retrun from $flex.web.help func
                print("Web Func Retrun ---------------")
                print(value!)
                print("-------------------------------")
            }
            return nil
        }
        
        // add user-custom contentController
        component.configration.userContentController.add(self, name: "userCC")
        // setBaseUrl
        component.setBaseUrl("file://")
        
        mWebView = FlexWebView(frame: self.view.frame, component: component)
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        mWebView.scrollView.bounces = false
        view.addSubview(mWebView)
        
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "html", inDirectory: "Script")!)))

        let db = DataBase()
        db.openDataBase()
        db.createVisitURL(url: mWebView.url!, date: Date())
        
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

    func keyChainInit() -> (Array<Any?>?) -> Any? {
        let keychain = Keychain(service: "kr.lay.HybridApp")
        return {(argument) -> String in
            guard keychain["UUID"] != nil else {
                do {
                    try keychain
                        .accessibility(.afterFirstUnlock)
                        .set(UUID().uuidString, key: "UUID")
                } catch let error {
                    print("error: \(error)")
                }
                return keychain["UUID"]!
            }
            return keychain["UUID"]!
        }
    }

    override
    func viewWillAppear(_ animated: Bool) {
        mWebView.navigationDelegate = self
        mWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("user navigationDelegate")
        mWebView.evaluateJavaScript("let a = window.open .....",completionHandler: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("user contentController")
    }
    
}
