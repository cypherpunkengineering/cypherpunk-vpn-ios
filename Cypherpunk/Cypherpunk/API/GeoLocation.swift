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

struct GeoLocationRequest: Request {
    
    typealias Response = GeoLocationResponse
    
    let IPAddress: String
    
    var baseURL: URL {
        return URL(string: "http://ip-api.com/json/")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return IPAddress
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> GeoLocationResponse {
        let response: Response = try decodeValue(object)
        
        return response
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
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
