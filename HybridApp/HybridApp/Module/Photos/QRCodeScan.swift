//
//  QRCodeScan.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import AVFoundation
import FlexHybridApp
/*
 QR코드스캔 모듈
 */
class QRCodeScan : NSObject {
    private var currentVC : UIViewController
    private var captureSession : AVCaptureSession?
    private var flexAction : FlexAction?
    private var previewLayer : CALayer!
    private var tempView : UIView!
    var resultValue: [String:Any] = [:]

    init (_ viewController : UIViewController){
        self.currentVC = viewController
    }
    
    func codeScanFunction() -> (FlexAction, Array<Any?>) -> Void {
        let loadingView = LoadingView(currentVC.view)
        return { (action, _) -> Void in
            
            Utils.setUserHistory(forKey: "QRCodeScanBtn")
            loadingView.showActivityIndicator(text: Msg.Loading, nil)
           
            if let captureSession = self.createCaptureSession() {
                self.captureSession = captureSession
                self.flexAction = action
                self.requestCaptureSessionStartRunning()
                DispatchQueue.main.async {
                    self.tempView = UIView(frame: self.currentVC.view.bounds)
                    self.tempView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                    self.currentVC.view.addSubview(self.tempView!)
                    self.previewLayer = self.createPreviewLayer(withCaptureSession : captureSession)
                    self.tempView.layer.addSublayer(self.previewLayer)
                    
                    let cancelBtn = UIButton(frame: CGRect(x: 0, y: self.currentVC.view.frame.height - 60, width: self.currentVC.view.frame.width / 3.5 , height: 50))
                    cancelBtn.center = CGPoint(x: self.currentVC.view.frame.size.width / 2.0, y : self.currentVC.view.frame.height - 60)
                    cancelBtn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    cancelBtn.layer.cornerRadius = 25
                    cancelBtn.setTitle("취소", for: .normal)
                    cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                    cancelBtn.addTarget(self, action: #selector(self.requestCaptureSessionStopRunning(sender:)), for: .touchUpInside)
                    self.tempView.addSubview(cancelBtn)
                    self.tempView.bringSubviewToFront(cancelBtn)
                }
            }
            loadingView.stopActivityIndicator()
        }
    }
}

extension QRCodeScan : AVCaptureMetadataOutputObjectsDelegate {
    
    private func createCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        resultValue["auth"] = false
        resultValue["data"] = nil
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            resultValue["msg"] = "Not Camera Device"
            flexAction?.promiseReturn(resultValue)
            return nil
        }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddInput(deviceInput){
                captureSession.addInput(deviceInput)
            } else {
                resultValue["msg"] = "cannot add input"
                flexAction?.promiseReturn(resultValue)
                return nil
            }
            
            if captureSession.canAddOutput(metaDataOutput){
                captureSession.addOutput(metaDataOutput)
                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = [.qr,
                                                      .code128,
                                                      .code39,
                                                      .code39Mod43,
                                                      .code93,
                                                      .ean8,
                                                      .ean13,
                                                      .interleaved2of5,
                                                      .itf14,
                                                      .pdf417,
                                                      .upce]
            } else {
                resultValue["msg"] = "cannot add output"
                flexAction?.promiseReturn(resultValue)
                return nil
            }
        } catch {
            resultValue["msg"] = error.localizedDescription
            flexAction?.promiseReturn(resultValue)
            return nil
        }
        
        return captureSession
    }
    
    public func metadataOutput(_ output : AVCaptureMetadataOutput,
                               didOutput metadataObjects : [AVMetadataObject],
                               from connection : AVCaptureConnection){

        resultValue["auth"] = true
        resultValue["data"] = nil
        resultValue["msg"] = nil
        
        if metadataObjects.count == 0 {
            flexAction?.promiseReturn(resultValue)
            self.requestCaptureSessionStopRunning(sender: nil)
            return
        }
        
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            resultValue["data"] = readableObject.stringValue
            flexAction?.promiseReturn(resultValue)
            flexAction = nil
            self.requestCaptureSessionStopRunning(sender: nil)
        }
        
    }

    func requestCaptureSessionStartRunning() {
        
        guard let captureSession = self.captureSession else {
            resultValue["auth"] = true
            resultValue["data"] = nil
            resultValue["msg"] = "captureSession is null"
            flexAction?.promiseReturn(resultValue)
            return
        }
        
        if !captureSession.isRunning{
            captureSession.startRunning()
        }
    }
    
    @objc func requestCaptureSessionStopRunning(sender : UIButton?) {
        
        guard let captureSession = self.captureSession else { return }
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.previewLayer.removeFromSuperlayer()
                self.tempView.removeFromSuperview()
                self.currentVC.view.isUserInteractionEnabled = true
            }
        }
        
        if sender != nil {
            resultValue["auth"] = true
            resultValue["data"] = nil
            resultValue["msg"] = "Stopped QR Code Scan"
            flexAction?.promiseReturn(resultValue)
        }
        
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer{
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
        previewLayer.frame = self.currentVC.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
}
