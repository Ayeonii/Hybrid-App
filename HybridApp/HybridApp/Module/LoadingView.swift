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
    
    func showActivityIndicator(text: String) {
        DispatchQueue.main.async {
            self.viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
            self.viewForActivityIndicator.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height) / 2.0)
            self.viewForActivityIndicator.layer.cornerRadius = 10
            self.viewForActivityIndicator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.598483033)
            self.backgroundView.addSubview(self.viewForActivityIndicator)
        
            self.activityIndicatorView.center = CGPoint(x: self.viewForActivityIndicator.frame.size.width / 2.0, y: (self.viewForActivityIndicator.frame.size.height) / 2.0 + 10)
        
            self.loadingTextLabel.textColor = UIColor.black
            self.loadingTextLabel.text = text
            self.loadingTextLabel.font = UIFont(name: "Avenir Light", size: 10)
            self.loadingTextLabel.sizeToFit()
            self.loadingTextLabel.center = CGPoint(x: self.activityIndicatorView.center.x, y: self.activityIndicatorView.center.y + 40)
            self.viewForActivityIndicator.addSubview(self.loadingTextLabel)
            
            self.activityIndicatorView.hidesWhenStopped = true
            self.activityIndicatorView.style = .whiteLarge
            self.activityIndicatorView.color = .black
            self.viewForActivityIndicator.addSubview(self.activityIndicatorView)
            
            self.backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            
            self.view.addSubview(self.backgroundView)
            self.activityIndicatorView.startAnimating()
        }
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
