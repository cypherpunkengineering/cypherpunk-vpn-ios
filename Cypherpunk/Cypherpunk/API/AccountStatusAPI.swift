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
        return URL(string: "https://cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/api/v0/account/status"
    }
    
    var headerFields: [String : String] {
        return ["Cookie": session]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }
}
