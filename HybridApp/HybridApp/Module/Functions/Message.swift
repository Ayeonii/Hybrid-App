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
    private var result : [String:Any] = [:]
    
    func sendMessge (_ currentVC : UIViewController)  -> (FlexAction, Array<Any?>?) -> Void {
        return { (action, argument) -> Void in
            
            Utils.setUserHistory(forKey: "SendMessageBtn")
            self.result["data"] = false
            self.result["msg"] = nil
            
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
                        self.result["msg"] = "메세지를 보낼 수 없습니다."
                        action.promiseReturn(self.result)
                    }
                }
            }else {
                self.result["msg"] = "전화번호와 내용을 적어주세요"
                action.promiseReturn(self.result)
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.sent:
            self.result["data"] = true
            self.result["msg"] = "문자메시지를 전송하였습니다."
        case MessageComposeResult.cancelled:
            self.result["data"] = false
            self.result["msg"] = "문자메시지 전송이 취소되었습니다."
        case MessageComposeResult.failed:
            self.result["data"] = false
            self.result["msg"] = "문자메시지 전송이 실패하였습니다."
            break
        default:
            self.result["data"] = false
            self.result["msg"] = "문자메시지 전송을 지원하지 않습니다."
        }
        self.flexAction.promiseReturn(self.result)
        DispatchQueue.main.async {  
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

