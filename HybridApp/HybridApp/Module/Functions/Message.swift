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
            
            if let number = argument?[0] as? String, let message = argument?[1] as? String {
                DispatchQueue.main.async {
                    let messageComposer = MFMessageComposeViewController()
                    messageComposer.messageComposeDelegate = self
                    if MFMessageComposeViewController.canSendText(){
                        self.flexAction = action
                        messageComposer.recipients = [number]
                        messageComposer.body = message
                        currentVC.present(messageComposer, animated: true, completion: nil)
                    } else {
                        action.PromiseReturn("메세지를 보낼 수 없습니다.")
                    }
                }
            }else {
                action.PromiseReturn("전화번호와 내용을 적어주세요")
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.sent:
            returnMsg = "문자메시지를 전송하였습니다."
            break
        case MessageComposeResult.cancelled:
            returnMsg = "문자메시지 전송이 취소되었습니다."
            break
        case MessageComposeResult.failed:
            returnMsg = "문자메시지 전송이 실패하였습니다."
            break
        default:
            returnMsg = "문자메시지 전송을 지원하지 않습니다."
            break
        }
        self.flexAction.PromiseReturn(returnMsg)
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

