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
    private var text = UITextView!
    
    func startFileDownload (_ component : FlexComponent) -> (FlexAction, Array<Any?>) -> Void?{
        return { (action, argument) -> Void in

            self.util.setUserHistory(forKey: "FileDownloadBtn")
            
            self.component = component
            DispatchQueue.main.async {
                self.loadingView = LoadingView(self.component.parentViewController!.view)
                self.loadingView.showActivityIndicator(text: "다운로드 중", nil)
            }
            self.flexAction  = action
            self.fileURL = argument[0] as? String
            self.component.evalFlexFunc("result", sendData: "Download Start!")
            self.fileDownload()
        }
    }
    
    func fileDownload() {
        guard let url = URL(string: fileURL) else {
            self.flexAction.PromiseReturn("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())

        let task = session.downloadTask (with: urlRequest)
        task.resume() //시작
    }

}

extension FileDownload: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
         if totalBytesExpectedToWrite > 0 {
             let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
             print("Progress \(downloadTask) \(progress)")
         }
     }
    
     func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager()
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("Downloads")
        
        let writePath = destinationFileUrl.appendingPathComponent(URL(string:self.fileURL)!.lastPathComponent)
        do {
            try FileManager.default.copyItem(at: location, to: writePath)
            self.openFileWithPath(filePath: writePath)
            self.loadingView.stopActivityIndicator()
        } catch (let writeError) {
            print("Error creating a file \(destinationFileUrl) : \(writeError)")
            self.loadingView.stopActivityIndicator()
        }
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
