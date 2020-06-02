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
    private var util = Utils()
    private var tempView : UIView!

    
    init (_ viewController : UIViewController){
        self.currentVC = viewController
    }
    
    func codeScanFunction() -> (FlexAction, Array<Any?>) ->Void? {
        var loadingView : UIView!
        return { (action, argument) -> Void in
            
            self.util.setUserHistory(forKey: "QRCodeScanBtn")
            DispatchQueue.main.async {
                loadingView = LoadingView().displaySpinner(onView: self.currentVC.view)
                self.currentVC.view.addSubview(loadingView)
            }
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
                    
                    let cancelBtn = UIButton(frame: CGRect(x: 0, y: self.currentVC.view.frame.height - 60, width: self.currentVC.view.frame.width, height: 60))
                    cancelBtn.backgroundColor = UIColor.lightGray
                    cancelBtn.setTitle("취소", for: .normal)
                    cancelBtn.addTarget(self, action: #selector(self.requestCaptureSessionStopRunning(sender:)), for: .touchUpInside)
                    self.tempView.addSubview(cancelBtn)
                }
            } else {
                action.PromiseReturn(nil)
            }
            LoadingView().removeSpinner(spinner: loadingView)
        }
    }
}

extension QRCodeScan : AVCaptureMetadataOutputObjectsDelegate {
    
    private func createCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return nil}
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddInput(deviceInput){
                captureSession.addInput(deviceInput)
            }else {
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
            }else {
                return nil
            }
        }catch{
            return nil
        }
        return captureSession
    }
    
    public func metadataOutput(_ output : AVCaptureMetadataOutput,
                               didOutput metadataObjects : [AVMetadataObject],
                               from connection : AVCaptureConnection){
        if metadataObjects.count == 0 {
            print ("No QR Code is detected")
            self.requestCaptureSessionStopRunning(sender: nil)
            return
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            flexAction?.PromiseReturn(stringValue)
            self.requestCaptureSessionStopRunning(sender: nil)
        }
        
    }

    func requestCaptureSessionStartRunning() {
        guard let captureSession = self.captureSession else {
            self.flexAction?.PromiseReturn("captureSession is null")
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
        self.flexAction?.PromiseReturn("Stopped QR Code")
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer{
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
        previewLayer.frame = CGRect(x:0, y:0, width:self.currentVC.view.frame.width, height: self.currentVC.view.frame.height - 60)
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
}
