//
//  GeoLocation.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/16.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import Himotoki
import APIKit

struct GeoLocationRequest: RequestType {
    
    typealias Response = GeoLocationResponse
    
    let IPAddress: String
    
    var baseURL: URL {
        return URL(string: "http://ip-api.com/json/")!
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var path: String {
        return IPAddress
    }
    
    func responseFromObject(_ object: AnyObject, URLResponse: HTTPURLResponse) throws -> Response {
        let response: Response = try decodeValue(object)
        
        return response
    }
    
    var dataParser: DataParserType {
        return JSONDataParser(readingOptions: .AllowFragments)
    }
}

struct GeoLocationResponse: Decodable {
    let status: String
    let country: String
    let lat: Double
    let lon: Double
    let query: String
    static func decode(_ e: Extractor) throws -> GeoLocationResponse {
        return try GeoLocationResponse(
            status: e.value("status"),
            country: e.value("country"),
            lat: e.value("lat"),
            lon: e.value("lon"),
            query: e.value("query")
        )
    }
    
    var isSuccess: Bool {
        return status == "success"
    }
        
}
