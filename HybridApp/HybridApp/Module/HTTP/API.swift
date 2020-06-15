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
    static let baseURL = "http://127.0.0.1"
}

class API {
    static let shared: API = API()
    
    private var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }

    func get(completionHandler: @escaping (Result<[CheckData], Error>) -> Void) {
        self.request = AF.request("\(Config.baseURL)/posts")
                        .responseDecodable { (response: DataResponse<[CheckData], AFError>) in
                            switch response.result {
                            case .success(let checkData):
                                completionHandler(.success(checkData))
                            case .failure(let error):
                                completionHandler(.failure(error))
                            }
                        }
    }
    
    func getParams(completionHandler: @escaping (Result<[CheckData], Error>) -> Void) {
        let parameters: Parameters = ["key": 1]
        self.request = AF.request("\(Config.baseURL)/posts", method: .get, parameters: parameters, encoding: URLEncoding.default)
                        .responseDecodable { (response: DataResponse<[CheckData], AFError>) in
                            switch response.result {
                            case .success(let checkData):
                                completionHandler(.success(checkData))
                            case .failure(let error):
                                completionHandler(.failure(error))
                            }
                        }
    }
    
    func post(completionHandler: @escaping (Result<[CheckData], Error>) -> Void) {
        let checkData = PostCheckData(codeSignData: "", machOData: "" )
        self.request = AF.request("\(Config.baseURL)/posts", method: .post, parameters: checkData).responseDecodable { (response: DataResponse<PostCheckData, AFError>) in
                            switch response.result {
                            case .success(let checkData):
                                completionHandler(.success([checkData.toCheckData()]))
                            case .failure(let error):
                                completionHandler(.failure(error))
                            }
                        }
    }
    
    
    
    
}
