//
//  UpgradeAPI.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/11/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import APIKit
import Himotoki

struct UpgradeRequest: Request {
    typealias Response = UpgradeResponse
    
    let session: String
    let accountId: String
    let planId: String
    let receipt: Data
    
    var baseURL: URL {
        return URL(string: "https://cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/api/v1/account/upgrade/iTunesAppStore"
    }
    
    var parameters: Any? {
        return [
            "account": accountId,
            "planId": planId,
            "transaction": receipt
        ]
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

struct UpgradeResponse: Decodable {
    let message: String
    let status: String
    let login: String
    static func decode(_ e: Extractor) throws -> UpgradeResponse {
        return try UpgradeResponse(
            message: e.value("message"),
            status: e.value("status"),
            login: e.value("login")
        )
    }
}
