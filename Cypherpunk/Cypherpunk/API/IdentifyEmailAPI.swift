//
//  IdentifyEmailAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/31.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import APIKit

protocol IdentifyEmailRequestType: Request {
    
}


struct IdentifyEmailRequest: IdentifyEmailRequestType {
    
    typealias Response = Bool
    
    var email: String
    var baseURL: URL {
        return URL(string: "https://cypherpunk.engineering")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/api/v0/account/identify/email"
    }
    
    var parameters: Any? {
        return ["email": email]
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
    
    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        return object
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        if urlResponse.statusCode == 401 {
            return false
        }
        else if urlResponse.statusCode == 200 {
            return true
        } else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        
    }
    
    

}

extension Request where Self: IdentifyEmailRequestType {
    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Bool {
        if urlResponse.statusCode == 401 {
            return false
        }
        else if urlResponse.statusCode == 200 {
            return false
        } else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
    }
}


