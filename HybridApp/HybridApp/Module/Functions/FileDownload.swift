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
class FileDownload : NSObject{
    
    private var flexAction : FlexAction!
    private var fileURL : String!
    private var interaction: UIDocumentInteractionController?
    private var component : FlexComponent
    private let util = Utils()
    private var loadingView : LoadingView!
    
    init(_ component : FlexComponent){
        self.component = component
    }
    
    func startFileDownload () -> (FlexAction, Array<Any?>) -> Void?{
        return { (action, argument) -> Void in
            self.util.setUserHistory(forKey: "FileDownloadBtn")
            
            self.loadingView = LoadingView(self.component.parentViewController!.view)
            self.loadingView.showActivityIndicator(text: "다운로드 중")
        
            self.flexAction  = action
            self.fileURL = argument[0] as? String
            
            self.component.evalFlexFunc("result", sendData: "Download Start!")
            
            self.fileDownload { (success, path) in
                DispatchQueue.main.async(execute: {
                    self.openFileWithPath(filePath: path)
                })
            }
        }
    }
    
    func fileDownload(completion: @escaping (_ success:Bool, _ filePath:URL) -> ()) {
        
        guard let url = URL(string: fileURL) else {
            self.flexAction.PromiseReturn("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                debugPrint("Error!!")
                print(error as Any)
                self.flexAction.PromiseReturn(error as Any)
                return
            }
            
            guard let responseData = data else {
                print("Error: data empty!!")
                self.flexAction.PromiseReturn("Error: data empty!!")
                return
            }
            
            let fileManager = FileManager()
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dataPath = documentsDirectory.appendingPathComponent("Downloads")
            
            if !documentsDirectory.pathComponents.contains("Downloads") {
                try? fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
            }
            
            do {
                let writePath = dataPath.appendingPathComponent(URL(string:self.fileURL)!.lastPathComponent)
                print(URL(string:self.fileURL)!.lastPathComponent)
                try responseData.write(to: writePath)
                completion(true, writePath)
                self.flexAction.PromiseReturn("Download Complete!")
                
            } catch let error as NSError {
                print("Error Writing File : \(error.localizedDescription)")
                self.flexAction.PromiseReturn("Error Writing File : \(error.localizedDescription)")
                return
            }
        }
        self.loadingView.stopActivityIndicator()
        task.resume()
    }
    
    func openFileWithPath(filePath : URL) {
        DispatchQueue.main.async {
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
