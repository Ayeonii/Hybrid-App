//
//  BioAuth.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
import LocalAuthentication

class BioAuth {
    var authDescriptions : String!
    
    lazy var auth = FlexClosure.action { (action, _) in
        Utils.setUserHistory(forKey: "BioAuthBtn")
        
        let authContext = LAContext()
        var error : NSError?
        
        var result = Utils.genResult()
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            result["auth"] = true
            
            switch authContext.biometryType {
            case .faceID:
                self.authDescriptions = "Face ID로 인증합니다."
                break
            case .touchID:
                self.authDescriptions = "Touch ID로 인증합니다."
                break
            default:
                self.authDescriptions = "비밀번호로 인증합니다."
                break
            }
            
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: self.authDescriptions)
            { (success, error) in
                if success {
                    result["data"] = true
                    action.promiseReturn(result)
                }
                else {
                    result["data"] = false
                    result["msg"] = error?.localizedDescription
                    action.promiseReturn(result)
                }
            }
        } else {
            result["data"] = false
            result["msg"] = AuthrizeStatus.disabled
            action.promiseReturn(result)
            print(error as Any)
        }
    }
    
}
