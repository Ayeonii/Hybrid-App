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
            let ai = UIActivityIndicatorView(style: .gray)
            ai.startAnimating()
            ai.center = spinnerView.center
            spinnerView.addSubview(ai)
        }
        
        return spinnerView
    }
    
    func removeSpinner(spinner : UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
