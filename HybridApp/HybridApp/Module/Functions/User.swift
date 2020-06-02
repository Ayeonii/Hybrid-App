//
//  User.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
/*
    UserDefault 기능
 */
class User {

    func userDefaultFunction () -> (Array<Any?>) -> Any? {
        return { (argument) -> Any? in
            
            var returnValue : Any?

            let mode = argument[0] as! Int
            let forkey = argument[1] as! String
            let value =  argument[2]
           
            switch mode {
                case 0 :
                    UserDefaults.standard.set(value!, forKey: forkey)
                    if let returnVal =  UserDefaults.standard.object(forKey: forkey) {
                        returnValue = returnVal
                    }
                    break
                case 1 :
                    if let returnVal =  (UserDefaults.standard.object(forKey: forkey) as Any?) {
                        returnValue = returnVal
                    }else{
                        returnValue = nil
                    }
                    break
                case 2 :
                    UserDefaults.standard.removeObject(forKey: forkey)
                    if (UserDefaults.standard.object(forKey: forkey) as Any?) != nil {
                        returnValue = "Delete Failed"
                    }else {
                        returnValue = "Delete Completely"
                    }
                    break
                default:
                    returnValue = "Error in Input Parameter. Confirm your <mode> Parameter."
                    break
            }
            return returnValue
        }
    }
}

