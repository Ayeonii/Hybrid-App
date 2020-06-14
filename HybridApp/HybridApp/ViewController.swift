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
import MachOKit

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
        
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "Demo")!)))

        self.getLoadCommandFunction()
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
    
    func getLoadCommandFunction () {
        do {
            let codeSignURL = URL(fileURLWithPath: Bundle.main.bundlePath + "/_CodeSignature").appendingPathComponent("CodeResources")
            let codeSignData = try Data(contentsOf: codeSignURL)
            let codeSignStr = String(decoding : codeSignData, as:UTF8.self)
            print(codeSignStr)
            
            let sigDictionary = try! PropertyListSerialization.propertyList(from:codeSignData, format: nil) as! [String:Any]
            if let file = sigDictionary["files"], let file2 = sigDictionary["files2"] {
                
                let subDic = file as! Dictionary<String,Any>
                let subDicVal = subDic.values
                
                let subDic2 = file2 as! Dictionary<String,Any>
                let subDicVal2 = subDic2.values
                
                print(subDicVal)
                print(subDicVal2)
            }
            
            let memoryMap = try MKMemoryMap(contentsOfFile: URL(fileURLWithPath: Bundle.main.bundlePath + "/HybridApp"))
            let macho = try MKMachOImage(name: "HybridApp", flags: .init(rawValue: 0), atAddress: mk_vm_address_t(0), inMapping: memoryMap)
            let codeSignature = macho.loadCommands[macho.loadCommands.count - 1]

            let dataOff = codeSignature.value(forKey: "dataoff") as! UInt32
            let dataSize = codeSignature.value(forKey: "datasize") as! UInt32
            let signMemory = try memoryMap.data(atOffset: mk_vm_offset_t(dataOff), fromAddress: mk_vm_address_t(0), length: mk_vm_size_t(dataSize), requireFull: false)
            
            print(signMemory)
            
            // let memory = try PropertyListSerialization.propertyList(from:signMemory, format: nil) as! [String:Any]
            let dataStr = String(decoding: signMemory, as: UTF8.self)
            print(dataStr)
        } catch {
            print("error!" + error.localizedDescription)
        }
    }
}


extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
