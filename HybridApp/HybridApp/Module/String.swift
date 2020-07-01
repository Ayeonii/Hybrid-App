//
//  String.swift
//  HybridApp
//
//  Created by 황견주 on 2020/06/18.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import Foundation

struct AuthrizeStatus {
    static let authorized = "Access Authorized."
    static let denied = "Access Denied"
    static let restricted = "Access Restricted"
    static let disabled = "Access disabled"
    static let error = "Error"
}

struct PathString {
    static let codSignature = "/_CodeSignature"
    static let codeResources = "CodeResources"
    static let excutableFile = "/HybridApp"
    static let dataOff = "dataoff"
    static let dataSize = "datasize"
    static let nonAuth = "비정상적인 접근입니다. 앱을 종료합니다."
}

struct Conf {
    static let SecurityUrl = "chathub.crabdance.com"
    static let BaseUrl = "file://"
}

struct Msg {
    static let Loading = "LOADING..."
    static let DownLoading = "DOWNLOAD..."
    static let UnknownError = "unknown error"
    static let Cancel = "Cancel work"
        
    static let NoCamera = "Camera cannot be called"
    static let NoPhotos = "Photos cannot be called"
}

struct Key {
    static let AppID = "APP_UUID"
}

struct J {
    static let J1 = "cydia://package/com.example.package"
    static let J2 = "/Applications/Cydia.app"
    static let J3 = "/Library/MobileSubstrate/MobileSubstrate.dylib"
    static let J4 = "/bin/bash"
    static let J5 = "/usr/sbin/sshd"
    static let J6 = "/etc/apt"
    static let J7 = "/usr/bin/ssh"
    static let J8 = "/private/var/lib/apt"
    static let J9 = "/Applications/Cydia.app"
    static let J10 = "/Library/MobileSubstrate/MobileSubstrate.dylib"
    static let J11 = "EntitlementsHash"
}
