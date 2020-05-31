//
//  Message.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import MessageUI
import FlexHybridApp

/*
 메세지 모듈 (송신)
 */

class Message : NSObject, MFMessageComposeViewControllerDelegate {
    
    private var returnMsg : String!
    private var flexAction : FlexAction!
    private let util = Utils()
    
    func sendMessge (_ currentVC : UIViewController)  -> (FlexAction, Array<Any?>?) -> Void? {
        return { (action, argument) -> Void in
            
            self.util.setUserHistory(forKey: "SendMessageBtn")
            self.flexAction = action
            
            let number = argument?[0] as! String
            let message = argument?[1] as! String
            
            DispatchQueue.main.async {
                let messageComposer = MFMessageComposeViewController()
                messageComposer.messageComposeDelegate = self
                if MFMessageComposeViewController.canSendText(){
                    messageComposer.recipients = [number]
                    messageComposer.body = message
                    currentVC.present(messageComposer, animated: true, completion: nil)
                }
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.sent:
            returnMsg = "Complete Sending Msg"
            break
        case MessageComposeResult.cancelled:
            returnMsg = "Sending msg cancelled"
            break
        case MessageComposeResult.failed:
            returnMsg = "fail to send Msg"
            break
        default:
            break
        }
        self.flexAction.PromiseReturn(returnMsg)
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

