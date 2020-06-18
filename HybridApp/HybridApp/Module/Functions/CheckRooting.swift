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
        
    func checkRootingFunction (_ currentVC : UIViewController) -> ((FlexAction, Array<Any?>) -> Void) {
        return{ (action, _) -> Void in
            
            Utils.setUserHistory(forKey: "RootingCheckBtn")
            var result = ""
            
            DispatchQueue.main.async{
                if self.hasJailbreak() {
                    result = "탈옥되었습니다."
                    let dialog = UIAlertController(title: nil, message: PathString.nonAuth, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default){
                        (action:UIAlertAction!) in
                        exit(0)
                    }
                    dialog.addAction(action)
                    currentVC.present(dialog, animated: true, completion: nil)
                } else {
                    result = "탈옥되지 않았습니다."
                }
                action.promiseReturn(result)
            }
        }
    }
    
    func hasJailbreak() -> Bool {
        
        guard let cydiaUrlScheme = NSURL(string: J.J1) else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }

        #if arch(i386) || arch(x86_64)
        return false
        #endif
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: J.J2) ||
            fileManager.fileExists(atPath: J.J3) ||
            fileManager.fileExists(atPath: J.J4) ||
            fileManager.fileExists(atPath: J.J5) ||
            fileManager.fileExists(atPath: J.J6) ||
            fileManager.fileExists(atPath: J.J7) ||
            fileManager.fileExists(atPath: J.J8) {
            return true
        }

        if canOpen(path: J.J9) ||
            canOpen(path: J.J10) ||
            canOpen(path: J.J4) ||
            canOpen(path: J.J5) ||
            canOpen(path: J.J6) ||
            canOpen(path: J.J7) {
            return true
        }

        do {
            try "".write(toFile: NSUUID().uuidString, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: NSUUID().uuidString)
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

