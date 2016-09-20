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

struct JSONIPRequest: Request {
    
    typealias Response = JSONIPResponse
    
    var baseURL: URL {
        return URL(string: "https://jsonip.com")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return ""
    }
    
    func response(from object: Any, urlResponse URLResponse: HTTPURLResponse) throws -> Response {
        let response: Response = try decodeValue(object)
        
        return response
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
}

struct JSONIPResponse: Decodable {
    let IPAddress: String
    static func decode(_ e: Extractor) throws -> JSONIPResponse {
        return try JSONIPResponse(
            IPAddress: e.value("ip")
        )
    }

}
