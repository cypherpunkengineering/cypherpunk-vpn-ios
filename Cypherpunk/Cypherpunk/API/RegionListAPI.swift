//
//  RegionListAPI.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import APIKit
import Himotoki
import RealmSwift

struct RegionListRequest: RequestType {
    
    typealias Response = ()
    
    let session: String
    
    var baseURL: NSURL {
        return NSURL(string: "https://cypherpunk.engineering")!
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    
    var path: String {
        return "/api/vpn/serverList"
    }
    
    
    var headerFields: [String : String] {
        return ["Cookie": session]
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        
        if let areaDictionary = object as? Dictionary<String, AnyObject> {
            
            let realm = try! Realm()
            try! realm.write({
                realm.deleteAll()
                for (_, list) in areaDictionary {
                    if let countriesDictionary = list as? Dictionary<String, AnyObject> {
                        for (_, list) in countriesDictionary {
                            if let cityList = list as? Array<Dictionary<String, String>> {
                                for city in cityList {
                                    let cityname = city["city"]
                                    let ip = city["ip"]
                                    
                                    let region = Region(name: cityname!, ipAddress: ip!)
                                    realm.add(region, update: true)
                                }
                            }
                        }
                    }
                }
            })
            
        } else {
            throw ResponseError.UnexpectedObject(object)
        }
    }
    
    var dataParser: DataParserType {
        return JSONDataParser(readingOptions: .AllowFragments)
    }
}


import Realm

class Region: Object {
    dynamic var name: String = ""
    dynamic var ipAddress: String = ""
    dynamic var isFavorite: Bool = false
    dynamic var isRecommended: Bool = false
    
    init(name: String, ipAddress: String) {
        super.init()

        self.name = name
        self.ipAddress = ipAddress
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    override static func primaryKey() -> String? {
        return "name"
    }
    
    override var hashValue: Int {
        return name != "" ? name.hashValue : 0
    }

}

func ==(lhs: Region, rhs:Region) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

private extension String {
    
    var sha256String: String {
        return self.digest(CC_SHA256_DIGEST_LENGTH, gen: {(data, len, md) in CC_SHA256(data,len,md)})
    }
    
    private func digest(length:Int32, gen:(data: UnsafePointer<Void>, len: CC_LONG, md: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>) -> String {
        var cStr = [UInt8](self.utf8)
        var result = [UInt8](count:Int(length), repeatedValue:0)
        gen(data: &cStr, len: CC_LONG(cStr.count), md: &result)
        
        let output = NSMutableString(capacity:Int(length))
        
        for r in result {
            output.appendFormat("%02x", r)
        }
        
        return String(output)
    }
    
}
