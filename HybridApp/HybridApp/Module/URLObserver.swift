//
//  URLObserver.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/01.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import UIKit

protocol Observer {
    func urlLogSaveUpdate (_ updateURL : URL)
}

class URLObserver {
    private var urlObservers = [Observer]()
    private var updateURL : URL!
    
    var url : URL {
        set {
            updateURL = newValue
           // urlLogSave(updateURL)
            notify()
        }
        get {
            updateURL
        }
    }
    
    func attachObserver(_ observer : Observer){
        urlObservers.append(observer)
    }
    
    func notify() {
        for observer in urlObservers {
            observer.urlLogSaveUpdate(url)
        }
    }
}

class ListeningObserver : Observer {
    
    private let db = DataBase()
    private var urlObserver = URLObserver()
    
    init(_ urlobserver: URLObserver) {
        self.urlObserver = urlobserver
        self.urlObserver.attachObserver(self)
        db.openDataBase()
    }
    
    func urlLogSaveUpdate(_ updateURL: URL) {
            let threeDaysAgo = Date(timeIntervalSinceNow: (-86400 * 3))
            db.deleteVisitURL(to : threeDaysAgo)
            db.createVisitURL(url: updateURL, date: Date())
            db.readVisitURL()
    }
}
