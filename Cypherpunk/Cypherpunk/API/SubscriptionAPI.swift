//
//  SubscriptionAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

struct SubscriptionStatusRequest: Request {
    typealias Response = SubscriptionStatus
    
    let session: String
    
    var baseURL: URL {
        return URL(string: "https://cypherpunk.engineering")!
    }
    
    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/subscription/status"
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

struct SubscriptionStatus: Decodable {
    let confirmed: Bool
    let expiration: String
    let renewal: String
    let type: String
    
    static func decode(_ e: Extractor) throws -> SubscriptionStatus {
        return try SubscriptionStatus(
            confirmed: e.value("confirmed") == 1,
            expiration: e.value("expiration"),
            renewal: e.value("renewal"),
            type: e.value("type")
        )
    }
}
