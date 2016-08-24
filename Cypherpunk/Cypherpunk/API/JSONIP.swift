//
//  JSONIP.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/23.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import APIKit
import Himotoki

struct JSONIPRequest: RequestType {
    
    typealias Response = JSONIPResponse
    
    var baseURL: NSURL {
        return NSURL(string: "https://jsonip.com")!
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var path: String {
        return ""
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        let response: Response = try decodeValue(object)
        
        return response
    }
    
    var dataParser: DataParserType {
        return JSONDataParser(readingOptions: .AllowFragments)
    }
}

struct JSONIPResponse: Decodable {
    let IPAddress: String
    static func decode(e: Extractor) throws -> JSONIPResponse {
        return try JSONIPResponse(
            IPAddress: e.value("ip")
        )
    }

}