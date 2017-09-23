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

struct CertificateRequest: Request {
    
    typealias Response = CertificateResponse
    
    let session: String
    
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headerFields: [String : String] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return [
            "Cookie": session,
            "User-Agent": "CypherpunkPrivacy/iOS/\(version)"
        ]
    }
    
    var path: String {
        return "/api/v1/vpn/certificate"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> CertificateResponse {
        return try decodeValue(object)
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: .allowFragments)
    }
}

struct CertificateResponse: Himotoki.Decodable {
    let p12: String
    
    static func decode(_ e: Extractor) throws -> CertificateResponse {
        return try CertificateResponse(p12: e.value("p12"))
    }
}

