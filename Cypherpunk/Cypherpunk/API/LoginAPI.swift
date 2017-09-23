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
        return "/api/v1/account/authenticate/userpasswd"
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

struct LoginResponse: Himotoki.Decodable {
    let secret: String
    let account: Account
    let privacy: Privacy
    let subscription: Subscription
    var session: String
    
    static func decode(_ e: Extractor) throws -> LoginResponse {
        return try LoginResponse(
            secret: e.value("secret"),
            account: e.value("account"),
            privacy: e.value("privacy"),
            subscription: e.value("subscription"),
            session: ""
        )
    }
}

struct Privacy: Himotoki.Decodable {
    let username: String
    let password: String
    
    static func decode(_ e: Extractor) throws -> Privacy {
        return try Privacy(
            username: e.value("username"),
            password: e.value("password")
        )
    }
    
}

struct Subscription: Himotoki.Decodable {
    let renewal: String
    let expiration: String
    let renews: Bool
    let active: Bool
    let type: String
    
    static func decode(_ e: Extractor) throws -> Subscription {
        return try Subscription(
            renewal: e.value("renewal"),
            expiration: e.value("expiration"),
            renews: e.value("renews"),
            active: e.value("active"),
            type: e.value("type")
        )
    }

}
struct Account: Himotoki.Decodable {
    let email: String
    let confirmed: Bool
    let type: String
    
    static func decode(_ e: Extractor) throws -> Account {
        return try Account(
            email: e.value("email"),
            confirmed: e.value("confirmed"),
            type: e.value("type")
        )
    }

}
