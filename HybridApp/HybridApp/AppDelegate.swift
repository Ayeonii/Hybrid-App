//
//  AppDelegate.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/14.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundCompletionHandler: (() -> Void)?
    var checkedCodeSignature: Bool = false
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // get Code Signature and nil check
        if !checkedCodeSignature {
            let codeSign = self.getCodeSignature()
            if codeSign == nil { Utils.forceCloseAlertDialog(self, title: "앱 위변조 검사", message: "앱이 위변조되었습니다.\n 앱을 다시 설치해주세요.") }
            else {
//                print("this app's Code Signature : \(codeSign!)")
                   
                // Code Signature Same Check
                validateCodeSignature(codeSign!)
            }
           
        }
        
    }
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.string(forKey: Key.AppID) == nil{
            UserDefaults.standard.set(UUID().uuidString, forKey: Key.AppID)
        }
        
        if #available(iOS 12.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings], completionHandler: {didAllow,Error in
                print(didAllow)
            })
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow,Error in
                print(didAllow)
            })
        }
        
        
        
        
        do {
            try Network.reachability = Reachability(hostname: Conf.SecurityUrl)
        }catch {
            switch error as? Network.Error {
                case let .failedToCreateWith(hostname)?:
                    print("Network error:\nFailed to create reachability object With host named:", hostname)
                case let .failedToInitializeWith(address)?:
                    print("Network error:\nFailed to initialize reachability object With address:", address)
                case .failedToSetCallout?:
                    print("Network error:\nFailed to set callout")
                case .failedToSetDispatchQueue?:
                    print("Network error:\nFailed to set DispatchQueue")
                case .none:
                    print(error)
            }
        }
        return true
    }

    /* Mach-o 에서 code signature 값 얻기 */
    func getCodeSignature() -> String? {
        let obj = MachOSignature()
        let dic = obj.loadCodeSignature()
        if dic != nil {
            return dic![AnyHashable(J.J11)] as? String
        }
        else {
            return nil
        }
    }
    
    /* code signature 일치 여부 판단 */
    func validateCodeSignature(_ codeSign: String) {
        let api = API.init()
        api.postCodeSign(codeSign: codeSign) { (result) -> Void in
            if(result) {
                print("mach-o Code Signature 일치!")
                self.checkedCodeSignature = true
            }
            else {
                print("mach-o Code Signature 불일치! 종료합니다.")
                Utils.forceCloseAlertDialog(self, title: "앱 위변조 검사", message: "앱이 위변조되었습니다.\n 앱을 다시 설치해주세요.") 
            }
        }
    }
    
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
  
}

