//
//  SignUpAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/31.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import APIKit

struct SignUpRequest: Request {

    typealias Response = String
    
    var email: String
    var password: String
    
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headerFields: [String : String] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return ["User-Agent":"CypherpunkPrivacy/iOS/\(version)"]
    }

    var path: String {
        return "/api/v0/account/register/signup"
    }
    
    var parameters: Any? {
        return [
            "email": email,
            "password": password
        ]
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if let cookie = urlResponse.allHeaderFields["Set-Cookie"] as? String {
            let separetedField = cookie.components(separatedBy: ";")
            if let session = separetedField.first {
                return session
            }
        }
        throw ResponseError.unexpectedObject(object)
    }


}
