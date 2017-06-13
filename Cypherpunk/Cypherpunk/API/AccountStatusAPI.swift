//
//  AccountStatusAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/11/28.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import Foundation
import APIKit
import Himotoki

struct AccountStatusRequest: Request {
    typealias Response = LoginResponse
    
    let session: String
    
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/api/v0/account/status"
    }
    
    var headerFields: [String : String] {
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return [
            "Cookie": session,
            "User-Agent": "CypherpunkPrivacy/iOS/\(version)"
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }
}
