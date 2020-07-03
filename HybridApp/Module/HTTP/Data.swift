//
//  Data.swift
//  HybridApp
//
//  Created by 이아연 on 2020/06/15.
//  Copyright © 2020 Ayeon. All rights reserved.
//

import Foundation


struct CheckData : Decodable {
    let codeSignData : String
    let machOData : String
}

struct PostCheckData : Codable {
    let codeSignData : String
    let machOData : String
    
    init(codeSignData : String, machOData : String){
        self.codeSignData = codeSignData
        self.machOData = machOData
    }
    
    func toCheckData() -> CheckData {
        return CheckData(codeSignData : codeSignData, machOData: machOData)
    }
}


