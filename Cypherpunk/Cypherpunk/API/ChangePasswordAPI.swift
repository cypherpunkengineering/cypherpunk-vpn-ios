//
//  ChangePasswordAPI.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/11/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

struct ChangePasswordRequest: Request {
    
    typealias Response = Bool
    
    let session: String
    let newPassword: String
    let oldPassword: String
    
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/api/v1/account/password/change"
    }
    
    var parameters: Any? {
        return [
            "newPassword": newPassword,
            "oldPassword": oldPassword
        ]
    }
    
    var headerFields: [String : String] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return [
            "Cookie": session,
            "User-Agent": "CypherpunkPrivacy/iOS/\(version)"
        ]
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard (200..<300).contains(urlResponse.statusCode) else {
            if urlResponse.statusCode == 402 {
                return object
            }
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if (400..<500).contains(urlResponse.statusCode) {
            // valid session needed
            return false
        }
        return true
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }
}
