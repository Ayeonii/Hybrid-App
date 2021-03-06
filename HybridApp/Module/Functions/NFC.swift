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

class NFC : NSObject{
    private var detectedMessages = Array<NFCNDEFMessage>()
    private var currentVC : UIViewController
    private var session : NFCNDEFReaderSession?
    
    init(_ currentVC : UIViewController){
        self.currentVC = currentVC
    }
    
    lazy var nfcReading = FlexClosure.action { (action, _) in
        guard NFCNDEFReaderSession.readingAvailable else {
            DispatchQueue.main.async {
                let alertController = UIAlertController (
                                            title: "Scanning Not Supported",
                                            message : "This device doesn't support tag scanning.",
                                            preferredStyle : .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler : nil))
                self.currentVC.present(alertController, animated: true, completion: nil)
            }
            return
        }
        self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.session?.alertMessage = ""
        self.session?.begin()
    }
    
    lazy var nfcWrite = FlexClosure.action { (action, _) in
        self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.session?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        self.session?.begin()
    }
    
}

extension NFC : NFCNDEFReaderSessionDelegate {
    
    //TagDetected
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
            self.detectedMessages.append(contentsOf: messages)
    }
    
    @available(iOS 13.0, *)
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                self.session?.restartPolling()
            })
            return
        }
        
        let tag = tags.first!
        self.session?.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if nil != error || nil == message {
                        statusMessage = "Fail to read NDEF from tag"
                    } else {
                        statusMessage = "Found 1 NDEF message"
                        DispatchQueue.main.async {
                            self.detectedMessages.append(message!)
                        }
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
            })
        })
    }
    
    //EndReading
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.currentVC.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.session = nil
    }
}
