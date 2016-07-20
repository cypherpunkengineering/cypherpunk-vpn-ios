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
    
    typealias Response = Region

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

            var areas: [Area] = []
            for (name, list) in areaDictionary {
                var countries: [Country] = []
                if let countriesDictionary = list as? Dictionary<String, AnyObject> {
                    for (name, list) in countriesDictionary {
                        var servers: [Server] = []
                        if let cityList = list as? Array<Dictionary<String, String>> {
                            for city in cityList {
                                servers.append(Server(value: city))
                            }
                        }
                        countries.append(Country(value: ["name": name, "servers": servers]))
                    }
                }
                areas.append(Area(value: ["name": name, "countries": countries]))
            }
            
            let region = Region(value: ["areas": areas])
            
            let realm = try! Realm()
            try! realm.write({
                realm.add(region, update: true)
            })
            return region
        } else {
            throw ResponseError.UnexpectedObject(object)
        }
    }
    
    var dataParser: DataParserType {
        return JSONDataParser(readingOptions: .AllowFragments)
    }
}


class Server: Object {
    dynamic var city: String = ""
    dynamic var ip: String = ""
    
    override static func primaryKey() -> String? {
        return "city"
    }
}

class Country: Object {
    dynamic var name: String = ""
    let servers = List<Server>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class Area: Object {
    dynamic var name: String = ""
    let countries = List<Country>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class Region: Object {
    dynamic var id = 0
    let areas = List<Area>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
