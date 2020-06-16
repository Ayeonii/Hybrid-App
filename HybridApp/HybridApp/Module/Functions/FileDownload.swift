//
//  FileDownload.swift
//  HybridApp
//
//  Created by 이아연 on 2020/05/31.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit
import FlexHybridApp

/*
 파일 다운로드
 */
class FileDownload : NSObject, URLSessionDelegate{
    
    private var flexAction : FlexAction!
    private var fileURL : String!
    private var interaction: UIDocumentInteractionController?
    private var component : FlexComponent!
    private let util = Utils()
    private var loadingView : LoadingView!
    private var progressLabel = UILabel()

    
    func startFileDownload (_ component : FlexComponent) -> (FlexAction, Array<Any?>) -> Void?{
        return { (action, argument) -> Void in

            self.util.setUserHistory(forKey: "FileDownloadBtn")
            
            self.component = component
            self.flexAction  = action
            self.fileURL = argument[0] as? String
            self.component.evalFlexFunc("result", sendData: "Download Start!")
            self.fileDownload()
        }
    }
    
    func fileDownload() {
        guard let url = URL(string: fileURL) else {
            self.flexAction.reject(reason: "There is no URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        DispatchQueue.main.async {
            let currentVC =  self.component.parentViewController!
           
            self.loadingView = LoadingView(currentVC.view)
            self.loadingView.showActivityIndicator(text: "다운로드 중..", nil)
            
            let loadingUIView = self.loadingView.getLoadingUIView()
            
            self.progressLabel.textColor = UIColor.white
            self.progressLabel.text = "0%"
            self.progressLabel.font = UIFont(name: "Avenir Light", size: UIFont.labelFontSize)
            self.progressLabel.sizeToFit()
            
            self.progressLabel.center = CGPoint(x: loadingUIView.center.x, y: loadingUIView.center.y - 30)
            
            loadingUIView.addSubview(self.progressLabel)
        }

        let task = session.downloadTask (with: urlRequest)
        task.resume() //시작
    }

}

extension FileDownload: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
         if totalBytesExpectedToWrite > 0 {
             let percentDownloaded = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100
            
            let StringPT = String(format: "%.1f", percentDownloaded)
            
            print("\(percentDownloaded)%")
            DispatchQueue.main.async {
                self.progressLabel.text = "\(StringPT)%"
                self.progressLabel.sizeToFit()
                self.progressLabel.textAlignment = .center
            }
         }
     }
    
     func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager()
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("Downloads")
        
        if !documentsUrl.pathComponents.contains("Downloads") {
            try? fileManager.createDirectory(atPath: destinationFileUrl.path, withIntermediateDirectories: false, attributes: nil)
        }
        
        var fileName = URL(string:self.fileURL)!.lastPathComponent
        var writePath = destinationFileUrl.appendingPathComponent(fileName)
        var index = 0
        
        while fileManager.fileExists(atPath: writePath.path) {
            print(fileName)
            index += 1
            let fileUrl = URL(string:self.fileURL)!
            fileName = fileUrl.deletingPathExtension().lastPathComponent + "(\(index))." + fileUrl.pathExtension
            writePath = destinationFileUrl.appendingPathComponent(fileName)
        }
        
        do {
            try FileManager.default.copyItem(at: location, to: writePath)
            self.openFileWithPath(filePath: writePath)
            self.loadingView.stopActivityIndicator()
            
        } catch (let writeError) {
            print("Error creating a file \(destinationFileUrl) : \(writeError)")
            self.loadingView.stopActivityIndicator()
        }
        try? FileManager.default.removeItem(at: location)
    }
    
    func readDownloadedData(of url: URL) -> Data? {
        do {
            let reader = try FileHandle(forReadingFrom: url)
            let data = reader.readDataToEndOfFile()
            
            return data
        } catch {
            print(error)
            return nil
        }
    }
    
    func openFileWithPath(filePath : URL) {
        DispatchQueue.main.async {
            self.loadingView.stopActivityIndicator()
            self.interaction = UIDocumentInteractionController(url: filePath)
            self.interaction?.delegate = self
            self.interaction?.presentPreview(animated: true)
        }
    }
}

extension FileDownload : UIDocumentInteractionControllerDelegate {
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.component.parentViewController!
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
        interaction = nil
    }
}
