//
//  API.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/15.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import Alamofire
import Foundation

struct Config {
    static let authURL = "https://chathub.crabdance.com:453/iOS"
}

class API {
    static let shared: API = API()
    
    private var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }

    func post(param1 : String, param2 : String, completionHandler: @escaping (Result<Any?, Error>) -> Void) {
        let checkData = [Utils.stringHash(targetString: "h1"): param1,
                         Utils.stringHash(targetString: "h2"): param2 ]
        //print(checkData)
        self.request = AF.request(Config.authURL, method: .post, parameters: checkData , encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300).responseString(){response in
            switch response.result {
                case .success(let checkData):
                    let statusCode = (response.response?.statusCode)! as Int
                    print(statusCode)
                    completionHandler(.success(checkData))
                case .failure(let error):
                    completionHandler(.failure(error))
            }
        }
    }
    
    func postCodeSign(codeSign : String, completionHandler: @escaping (Bool) -> Void) {
        let data = ["hash" : codeSign]
        let header: HTTPHeaders = ["Content-Type":"application/json", "Accept":"application/json"]

        //print(checkData)
        self.request = AF.request(Config.authURL, method: .post, parameters: data , encoder: JSONParameterEncoder.default, headers: header).validate(statusCode: 200..<300).responseString(){response in
            switch response.result {
                case .success:
                    let statusCode = (response.response?.statusCode)! as Int
                    print("codeSign Status : \(statusCode)")
                    completionHandler(true)
                case .failure:
                    let statusCode = (response.response?.statusCode)! as Int
                    print("codeSign Status : \(statusCode)")
                    completionHandler(false)
            }
        }
    }
}
