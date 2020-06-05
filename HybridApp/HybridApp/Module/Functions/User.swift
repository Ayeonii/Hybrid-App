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

            if argument.count < 2 {
                return "파라미터 수를 확인해 주세요."
            }
            
            guard let mode = (argument[0] as? Int) else { return "1번째 파라미터를 확인해주세요"}
            guard let forkey = (argument[1] as? String) else { return "2번째 파라미터를 확인해주세요"}
            
            
            var value : Any?
            if(argument.count > 2){
                value =  argument[2]
            }
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
                        returnValue = "해당 Data Key에 대한 데이터가 존재하지 않습니다."
                    }
                    break
                case 2 :
                    if (UserDefaults.standard.object(forKey: forkey) as Any?) != nil {
                        UserDefaults.standard.removeObject(forKey: forkey)
                        if (UserDefaults.standard.object(forKey: forkey) as Any?) != nil {
                                               returnValue = "Delete Failed"
                                           }else {
                                               returnValue = "Delete Completely"
                                           }
                    } else {
                        returnValue = "해당 Data Key에 대한 데이터가 존재하지 않습니다."
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

