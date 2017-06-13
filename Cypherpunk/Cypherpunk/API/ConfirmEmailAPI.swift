//
//  ConfirmEmailAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/11/22.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import APIKit

struct ConfirmEmailRequest: Request {
    
    typealias Response = ()
    
    var email: String
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/api/v1/account/email/confirm"
    }
    
    var parameters: Any? {
        return ["email": email]
    }
    
    var headerFields: [String : String] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return ["User-Agent":"CypherpunkPrivacy/iOS/\(version)"]
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
    }
    
}

