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

struct LoginRequest: RequestType {
    
    typealias Response = LoginResponse
    
    let login: String
    let password: String
    
    var baseURL: NSURL {
        return NSURL(string: "https://cypherpunk.engineering")!
    }

    var method: HTTPMethod {
        return .POST
    }
    
    
    var path: String {
        return "/account/authenticate/userpasswd"
    }
    
    var parameters: AnyObject? {
        return [
            "login": login,
            "password": password,
        ]
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
    
    var dataParser: DataParserType {
        return JSONDataParser(readingOptions: .AllowFragments)
    }
}

struct LoginResponse: Decodable {
    let secret: String
    let account: Account
    
    static func decode(e: Extractor) throws -> LoginResponse {
        return try LoginResponse(
            secret: e.value("secret"),
            account: e.value("acct")
        )
    }
}

struct Account: Decodable {
    let email: String
    let powerLevel: Int

    static func decode(e: Extractor) throws -> Account {
        return try Account(
            email: e.value("email"),
            powerLevel: e.value("powerLevel")
        )
    }

}