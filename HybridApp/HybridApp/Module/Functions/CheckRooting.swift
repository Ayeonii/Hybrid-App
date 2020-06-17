//
//  CheckRooting.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

/*
 권한 / 루팅체킹 모듈
 */
class CheckRooting {
    
    let util = Utils()
    
    func checkRootingFunction (_ currentVC : UIViewController) -> ((Array<Any?>) -> Any?) {
        return{ (_) -> String in
            
            self.util.setUserHistory(forKey: "RootingCheckBtn")
            
            var returnStr : String = "Not Root Authority"
            DispatchQueue.main.async{
                if self.hasJailbreak() {
                    returnStr = "RootAuthority"
                    let dialog = UIAlertController(title: nil, message: PathString.nonAuth.rawValue, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default){
                        (action:UIAlertAction!) in
                        exit(0)
                    }
                    dialog.addAction(action)
                    currentVC.present(dialog, animated: true, completion: nil)
                }
            }
            return returnStr
        }
    }
    
    func hasJailbreak() -> Bool {
        
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }
        
        #if arch(i386) || arch(x86_64)
        return false
        #endif
        
        //file check
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            return true
        }
        
        //rootAutority check
        if canOpen(path: "/Applications/Cydia.app") ||
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            canOpen(path: "/bin/bash") ||
            canOpen(path: "/usr/sbin/sshd") ||
            canOpen(path: "/etc/apt") ||
            canOpen(path: "/usr/bin/ssh") {
            return true
        }
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
}

