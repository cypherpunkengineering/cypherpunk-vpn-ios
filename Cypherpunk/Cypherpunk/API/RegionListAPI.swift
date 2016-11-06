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

struct RegionListRequest: Request {
    
    typealias Response = ()
    
    let session: String
    
    var baseURL: URL {
        return URL(string: "https://cypherpunk.engineering")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    
    var path: String {
        return "/api/v0/vpn/serverList"
    }
    
    
    var headerFields: [String : String] {
        return ["Cookie": session]
    }
    
    func response(from object: Any, urlResponse URLResponse: HTTPURLResponse) throws -> Response {
        
        if let areaDictionary = object as? Dictionary<String, AnyObject> {
            
            let realm = try! Realm()
            try! realm.write({
                var regionIds: [String] = []
                for (_, list) in areaDictionary {
                    if let countriesDictionary = list as? Dictionary<String, AnyObject> {
                        for (country, list) in countriesDictionary {
                            if let serverList = list as? Array<Dictionary<String, Any>> {
                                for server in serverList {
                                    let id = server["id"]
                                    if let region = realm.object(ofType: Region.self, forPrimaryKey: id!) {
                                        region.regionName = server["regionName"] as! String
                                        region.ovHostname = server["ovHostname"] as! String
                                        region.ovDefault = server["ovDefault"] as! String
                                        region.ovNone = server["ovNone"] as! String
                                        region.ovStrong = server["ovStrong"] as! String
                                        region.ovStealth = server["ovStealth"] as! String
                                        region.ipsecHostname = server["ipsecHostname"] as! String
                                        region.ipsecDefault = server["ipsecDefault"] as! String
                                        region.httpDefault = server["httpDefault"] as! String
                                        region.socksDefault = server["socksDefault"] as! String
                                        region.countryCode = country
                                    } else {
                                        let region = Region(
                                            id: id as! String,
                                            regionName: server["regionName"] as! String,
                                            ovHostname: server["ovHostname"] as! String,
                                            ovDefault: server["ovDefault"] as! String,
                                            ovNone: server["ovNone"] as! String,
                                            ovStrong: server["ovStrong"] as! String,
                                            ovStealth: server["ovStealth"] as! String,
                                            ipsecHostname: server["ipsecHostname"] as! String,
                                            ipsecDefault: server["ipsecDefault"] as! String,
                                            httpDefault: server["httpDefault"] as! String,
                                            socksDefault: server["socksDefault"] as! String,
                                            countryCode: country
                                        )
                                        realm.add(region, update: true)
                                    }
                                    regionIds.append(id as! String)
                                }
                            }
                        }
                    }
                }
                let oldRegions = realm.objects(Region.self).filter("NOT (id IN %@)", regionIds)
                realm.delete(oldRegions)
                
            })
            
        } else {
            throw ResponseError.unexpectedObject(object)
        }
    }
    
    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }
}


import Realm

class Region: Object {
    dynamic var id: String = ""
    dynamic var regionName: String = ""
    dynamic var ovHostname: String = ""
    dynamic var ovDefault: String = ""
    dynamic var ovNone: String = ""
    dynamic var ovStrong: String = ""
    dynamic var ovStealth: String = ""
    dynamic var ipsecHostname: String = ""
    dynamic var ipsecDefault: String = ""
    dynamic var httpDefault: String = ""
    dynamic var socksDefault: String = ""
    dynamic var countryCode: String = ""
    dynamic var isFavorite: Bool = false
    dynamic var lastConnectedDate: Date = Date(timeIntervalSince1970: 1)
    
    init(id: String, regionName: String, ovHostname: String, ovDefault: String, ovNone: String, ovStrong: String, ovStealth: String, ipsecHostname: String, ipsecDefault: String, httpDefault: String, socksDefault: String, countryCode: String) {

        super.init()
        
        self.id = id
        self.regionName = regionName
        self.ovHostname = ovHostname
        self.ovDefault = ovDefault
        self.ovNone = ovNone
        self.ovStrong = ovStrong
        self.ovStealth = ovStealth
        self.ipsecDefault = ipsecDefault
        self.ipsecHostname = ipsecHostname
        self.httpDefault = httpDefault
        self.socksDefault = socksDefault
        self.countryCode = countryCode
        self.isFavorite = false
    }
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var hashValue: Int {
        return id != "" ? id.hashValue : 0
    }

}

func ==(lhs: Region, rhs:Region) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
