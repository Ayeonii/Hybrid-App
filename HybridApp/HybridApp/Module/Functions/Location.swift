//
//  Location.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
import CoreLocation
/*
 위치모듈
 */
class Location: NSObject{
    
    private let util = Utils()
    private var returnLocation = Dictionary<String,String?> ()
    private let currentVC : UIViewController
    private var locationManager = CLLocationManager()
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    func locationFunction() -> ((Array<Any?>?) -> Any?) {
        return { (arguments) -> Dictionary<String,Any?>  in
            
            self.util.setUserHistory(forKey: "LocationBtn")
            
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways, .authorizedWhenInUse :
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                print ("getlocation")
                let coor = self.locationManager.location?.coordinate
                let latitude = coor?.latitude
                let longtitude = coor?.longitude
                if let la = latitude , let lo = longtitude {
                    self.returnLocation.updateValue(String(describing : la ), forKey: "latitude")
                    self.returnLocation.updateValue(String(describing : lo ), forKey: "longtitude")
                }
                break
            case .denied, .restricted :
                self.util.setAuthAlertAction(currentVC : self.currentVC, dialog: self.util.authDialog)
                break
            case .notDetermined :
                self.returnLocation.removeAll()
                self.locationManager.requestWhenInUseAuthorization()
                break
            default :
                break
            }
            return self.returnLocation
        }
    }
}

extension Location : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedAlways || status == .authorizedWhenInUse){
            locationManager.delegate = self
            print(AuthrizeStatus.authorized.rawValue)
        }
    }
}
