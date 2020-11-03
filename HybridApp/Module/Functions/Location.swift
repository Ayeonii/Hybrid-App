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
class Location: NSObject, CLLocationManagerDelegate{
    
    private let currentVC : UIViewController
    private var locationManager = CLLocationManager()
    private var locationAction : FlexAction? = nil
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
        super.init()
        locationManager.delegate = self
    }
    
    lazy var location = FlexClosure.action { (action, _) in
        Utils.setUserHistory(forKey: "LocationBtn")
        self.locationAction = action
        self.getLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        getLocation()
    }
    
    private func getLocation() {
        var resultValue = Utils.genResult()
                    
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            resultValue["auth"] = true
            var location = Dictionary<String,String?>()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            let coor = self.locationManager.location?.coordinate
            let latitude = coor?.latitude
            let longtitude = coor?.longitude
            if let la = latitude , let lo = longtitude {
                location.updateValue(String(describing : la ), forKey: "latitude")
                location.updateValue(String(describing : lo ), forKey: "longtitude")
            }
            resultValue["data"] = location
            locationAction?.promiseReturn(resultValue)
            break
        case .denied, .restricted :
            resultValue["msg"] = AuthrizeStatus.denied
            locationAction?.promiseReturn(resultValue)
            Utils.setAuthAlertAction(currentVC : self.currentVC, dialog: Utils.authDialog)
            break
        case .notDetermined :
            self.locationManager.requestWhenInUseAuthorization()
            break
        default:
            resultValue["msg"] = Msg.UnknownError
            locationAction?.promiseReturn(resultValue)
            break
        }
        
    }
}
