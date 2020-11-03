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
    
    lazy var userDefault = FlexClosure.string { (argument) -> String in
        var returnValue : String = "No Value"

        if argument.count < 2 {
            return "파라미터 수를 확인해 주세요."
        }
        
        guard let mode = (argument[0].asInt()) else { return "1번째 파라미터를 확인해주세요"}
        guard let forkey = (argument[1].asString()) else { return "2번째 파라미터를 확인해주세요"}
        
        
        var value : String?
        if(argument.count > 2){
            value =  argument[2].toString()
        }
        switch mode {
            case 0 :
                UserDefaults.standard.set(value!, forKey: forkey)
                if let returnVal = UserDefaults.standard.string(forKey: forkey) {
                    returnValue = returnVal
                }
                break
            case 1 :
                if let returnVal =  (UserDefaults.standard.string(forKey: forkey)) {
                    returnValue = returnVal
                }else{
                    returnValue = "No Value"
                }
                break
            case 2 :
                if (UserDefaults.standard.object(forKey: forkey) as Any?) != nil {
                    UserDefaults.standard.removeObject(forKey: forkey)
                    if (UserDefaults.standard.object(forKey: forkey) as Any?) != nil {
                        returnValue = "Delete Failed"
                    } else {
                        returnValue = "Delete Completely"
                    }
                } else {
                    returnValue = "No Value"
                }
                break
            default:
                returnValue = "Error in Input Parameter. Confirm your <mode> Parameter."
                break
        }
        return returnValue
    }
    
}

