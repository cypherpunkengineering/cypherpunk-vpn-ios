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

    typealias Response = ()
    
    var email: String
    var password: String
    
    var baseURL: URL {
        return URL(string: "https://cypherpunk.engineering")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/account/register/signup"
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
    }


}
