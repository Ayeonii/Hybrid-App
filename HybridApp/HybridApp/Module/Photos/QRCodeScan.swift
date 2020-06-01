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
    private let qrCodeFrameView = UIView()
    private let view : UIView
    private var previewLayer : CALayer!
    private var util = Utils()
    
    init (_ viewController : UIViewController){
        self.currentVC = viewController
        self.view = viewController.view
    }
    
    func codeScanFunction() -> (FlexAction, Array<Any?>?) ->Void? {
        return { (action, argument) -> Void in
            
            self.util.setUserHistory(forKey: "QRCodeScanBtn")
            
            self.flexAction = action
            if let captureSession = self.createCaptureSession(){
                self.captureSession = captureSession

                DispatchQueue.main.async {
                    self.previewLayer = self.createPreviewLayer(withCaptureSession : captureSession)
                    
                    self.view.isUserInteractionEnabled = false
                    self.view.layer.addSublayer(self.previewLayer)
                    
                    self.qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    self.qrCodeFrameView.layer.borderWidth = 2
                    
                    self.view.addSubview(self.qrCodeFrameView)
                    self.view.bringSubviewToFront(self.qrCodeFrameView)
                    
                }
                self.requestCaptureSessionStartRunning()
            }
        }
    }
}

extension QRCodeScan : AVCaptureMetadataOutputObjectsDelegate{
    
    private func createCaptureSession() -> AVCaptureSession?{
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
        self.scannerDelegate(output, didOutput: metadataObjects, from: connection)
        
    }
    
    func scannerDelegate (_ output : AVCaptureMetadataOutput,
                          didOutput metadataObjects: [AVMetadataObject],
                          from connection: AVCaptureConnection){
        if metadataObjects.count == 0 {
            print ("No QR Code is detected")
            self.requestCaptureSessionStopRunning()
            return
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            flexAction?.PromiseReturn(stringValue)
            self.requestCaptureSessionStopRunning()
        }
    }
    
    func requestCaptureSessionStartRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if !captureSession.isRunning{
            captureSession.startRunning()
        }
    }
       
    func requestCaptureSessionStopRunning() {
        guard let captureSession = self.captureSession else { return }
        
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.previewLayer.removeFromSuperlayer()
                self.view.isUserInteractionEnabled = true
            }
        }
        self.flexAction?.PromiseReturn("Stop QR Code")
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer{
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
}
