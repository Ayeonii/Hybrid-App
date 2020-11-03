//
//  KeyChain.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/01.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
import KeychainAccess

class KeyChain: NSObject {
    
    lazy var keyChainInit = FlexClosure.string { (_) -> String in
        let keychain = Keychain(service: "kr.lay.HybridApp")
        guard keychain["UUID"] != nil else {
            do {
                try keychain
                    .accessibility(.afterFirstUnlock)
                    .set(UUID().uuidString, key: "UUID")
            } catch let error {
                print("error: \(error)")
            }
            return keychain["UUID"]!
        }
        return keychain["UUID"]!
    }
    
}
