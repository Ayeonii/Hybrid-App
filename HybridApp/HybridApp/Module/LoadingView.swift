//
//  LoadingView.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/02.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit

class LoadingView {
    
    let viewForActivityIndicator = UIView()
    let backgroundView = UIView()
    let view: UIView
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    
    init(_ view : UIView){
        self.view = view
    }
    
    func showActivityIndicator(text: String,  _ handler : (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
            self.viewForActivityIndicator.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height) / 2.0)
            self.viewForActivityIndicator.layer.cornerRadius = 15
            self.viewForActivityIndicator.backgroundColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5)
            self.backgroundView.addSubview(self.viewForActivityIndicator)
        
            self.activityIndicatorView.center = CGPoint(x: self.viewForActivityIndicator.frame.size.width / 2.0, y: (self.viewForActivityIndicator.frame.size.height) / 2.0)
        
            self.loadingTextLabel.textColor = UIColor.white
            self.loadingTextLabel.text = text
            self.loadingTextLabel.font = UIFont(name: "Avenir Light", size: UIFont.labelFontSize * 0.7)
            self.loadingTextLabel.sizeToFit()
            self.loadingTextLabel.center = CGPoint(x: self.activityIndicatorView.center.x, y: self.viewForActivityIndicator.frame.size.height * 0.85)
            
            self.viewForActivityIndicator.addSubview(self.loadingTextLabel)
            
            self.activityIndicatorView.hidesWhenStopped = true
            self.activityIndicatorView.style = .whiteLarge
            self.activityIndicatorView.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            self.viewForActivityIndicator.addSubview(self.activityIndicatorView)
            
            self.backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            self.activityIndicatorView.startAnimating()
            self.view.backgroundColor = .black
            self.view.addSubview(self.backgroundView)

        }
        if let handler = handler {
            handler()
        }
    }
    
    func getLoadingUIView () -> UIView{
        return self.activityIndicatorView
    }

    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.viewForActivityIndicator.removeFromSuperview()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
}
