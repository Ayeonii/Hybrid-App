//
//  OpenVoice.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit

class openVoice {
    
    func openVoiceScheme() -> (Array<Any?>?) -> Any {
        return { (argumnet) -> String in
        guard let schemeURL = URL(string: "voicememos://") else{
            return "Cannot Open"
        }
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(schemeURL){
                    print(schemeURL)
                    UIApplication.shared.open(schemeURL, options: [:], completionHandler: {
                        (bool) -> Void in
                        print(bool)
                    })
                }
            }
            return "VoiceApp"
        }
    }
}
