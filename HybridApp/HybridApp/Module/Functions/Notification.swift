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
    
    func notifiFunction () -> ( Array<Any?>) -> Any? {
        return {(arguments) -> Bool in
            
            self.util.setUserHistory(forKey: "NotificationBtn")
            
            let content = UNMutableNotificationContent()
            if let recieveData = arguments[0] as? Dictionary< String , Any?>
            {
                content.title = recieveData["title"] as? String ?? ""
                content.subtitle = recieveData["subTitle"] as? String ?? ""
                content.body = recieveData["message"] as? String ?? ""
                content.badge = NSNumber(value: recieveData["badge"] as? Int ?? 0)
                
                let identifier = recieveData["identifier"] as? String ?? "default"
                let isRepeat = recieveData["isRepeat"] as? Bool ?? false
                var sec = recieveData["duration"] as! Double
                if sec <= 0{
                    sec = 0.01
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sec , repeats:isRepeat)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                
                center.delegate = self
                center.add(request, withCompletionHandler: nil)
                
                return true
            } else {
                return false
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        self.currentVC.present(self.currentVC, animated: true, completion: nil)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {

        return completionHandler(UNNotificationPresentationOptions.alert)
    }
}
