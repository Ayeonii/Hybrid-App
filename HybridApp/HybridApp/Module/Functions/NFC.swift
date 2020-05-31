//
//  NFC.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp
#if canImport(CoreNFC)
import CoreNFC //NFC
#endif

#if canImport(CoreNFC)
class NFC : NSObject, NFCNDEFReaderSessionDelegate{
    
    private var nfcSession : NFCNDEFReaderSession!
    private var flexAction : FlexAction!
    private var nfcString : Array<String>!
    private let util = Utils()
    
    func nfcReadingFunction () -> (FlexAction, Array<Any?>?)-> Void? {
        return { (action, argument) -> Void in
            self.util.setUserHistory(forKey: "NFCBtn")
            self.flexAction = action
            self.nfcSession = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
            self.nfcSession.begin()
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let string = String(data: record.payload, encoding: .ascii) {
                    self.nfcString.append(string)
                    print(string)
                }
            }
        }
        flexAction.PromiseReturn(self.nfcString)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC Reading Error : ", error.localizedDescription)
    }
}
#endif
