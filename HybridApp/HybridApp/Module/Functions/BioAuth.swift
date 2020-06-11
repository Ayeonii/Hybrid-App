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
    let util = Utils()
    
    func authFunction() -> (FlexAction, Array<Any?>) -> Void {
        return { (action,  arguments) -> Void in
            
            self.util.setUserHistory(forKey: "BioAuthBtn")
            
            let authContext = LAContext()
            var error : NSError?
            
            guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                print ("Auth Disabled")
                action.promiseReturn(AuthrizeStatus.disabled.rawValue)
                print(error as Any)
                return
            }
            
            switch authContext.biometryType {
            case .faceID:
                self.authDescriptions = "Face ID로 인증합니다."
                break
            case .touchID:
                self.authDescriptions = "지문 인식해주세용"
                break
            default:
                self.authDescriptions = "로그인하세용"
                break
            }
            
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: self.authDescriptions){ (success, error) in
                if success {
                    print("인식 성공")
                    action.promiseReturn(AuthrizeStatus.authorized.rawValue)
                }
                else {
                    if let error = error {
                        print(error.localizedDescription)
                        action.promiseReturn(error.localizedDescription)
                    }
                    action.promiseReturn(AuthrizeStatus.denied.rawValue)
                }
            }
        }
    }
}


