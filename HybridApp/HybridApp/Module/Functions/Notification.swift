//
//  Notification.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
import UserNotifications

/*
 노티피케이션
 */
class Notification: NSObject, UNUserNotificationCenterDelegate {
    
    private let currentVC : UIViewController
    private let util = Utils()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func notifiFunction () -> ( Array<Any?>) -> Any?{
        return {(arguments) -> String in
            
            self.util.setUserHistory(forKey: "NotificationBtn")
            let data = Data("Array<Any?>?".utf8)
            print(data)
            let content = UNMutableNotificationContent()
            content.title = arguments[0] as! String
            content.subtitle = arguments[1] as? String ?? ""
            content.body = arguments[2] as! String
            content.badge = NSNumber(value: arguments[3] as! Int)
            
            let identifier = arguments[4] as! String
            let isRepeat = arguments[5] as! Bool
            
            let sec = arguments[6] as! Double
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sec , repeats:isRepeat)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request, withCompletionHandler: nil)
            
            return "Notification Activate!"
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        self.currentVC.present(self.currentVC, animated: true, completion: nil)
    }
       
}
