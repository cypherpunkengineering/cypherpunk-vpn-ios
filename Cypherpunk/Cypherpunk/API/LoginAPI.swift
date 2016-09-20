//
//  LoginAPI.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/19.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import APIKit
import Himotoki

struct LoginRequest: Request {
    
    typealias Response = LoginResponse
    
    let login: String
    let password: String
    
    var baseURL: URL {
        return URL(string: "https://cypherpunk.engineering")!
    }

    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/account/authenticate/userpasswd"
    }
    
    var parameters: Any? {
        return [
            "login": login,
            "password": password,
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LoginResponse {
        var response: Response = try decodeValue(object)
        
        if let cookie = urlResponse.allHeaderFields["Set-Cookie"] as? String {
            let separetedField = cookie.components(separatedBy: ";")
            if let session = separetedField.first {
                response.session = session
            }
        }
        
        return response
        
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
}

struct LoginResponse: Decodable {
    let secret: String
    let account: Account
    var session: String
    
    static func decode(_ e: Extractor) throws -> LoginResponse {
        return try LoginResponse(
            secret: e.value("secret"),
            account: e.value("acct"),
            session: ""
        )
    }
}

struct Account: Decodable {
    let email: String
    let powerLevel: Int

    static func decode(_ e: Extractor) throws -> Account {
        return try Account(
            email: e.value("email"),
            powerLevel: e.value("powerLevel")
        )
    }

}
