//
//  LoadingView.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/02.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit

class LoadingView: NSObject {
    
    func displaySpinner (onView : UIView) -> UIView {
        let spinnerView = UIView(frame : onView.bounds)
        
        DispatchQueue.main.async {
            spinnerView.backgroundColor = UIColor(white: 1, alpha: 0)
            let loadingCircle = UIActivityIndicatorView(style: .gray)
            loadingCircle.startAnimating()
            loadingCircle.center = spinnerView.center
            spinnerView.addSubview(loadingCircle)
        }
        return spinnerView
    }
    
    func removeSpinner(spinner : UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
