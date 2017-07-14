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

let regionUpdateNotification = Notification.Name("com.cypherpunk.regionUpdateNotificationKey")

struct RegionListRequest: Request {
    
    typealias Response = ()
    
    let session: String
    let accountType: String
    
    var baseURL: URL {
        return URL(string: "https://api.cypherpunk.com")!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    
    var path: String {
        return "/api/v1/location/list/\(accountType)"
    }
        
    var headerFields: [String : String] {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return [
            "Cookie": session,
            "User-Agent": "CypherpunkPrivacy/iOS/\(version)"
        ]
    }
    
    func response(from object: Any, urlResponse URLResponse: HTTPURLResponse) throws -> Response {
        
        if let areaDictionary = object as? Dictionary<String, [String: Any]> {
            
            var defaultRegion: Region?
            
            let realm = try! Realm()
            
            try! realm.write({
                var regionIds: [String] = []

                areaDictionary.values.forEach({ (server) in
                    let id = server["id"]
                    if let region = realm.object(ofType: Region.self, forPrimaryKey: id!) {
                        region.region = server["region"] as! String
                        region.level = server["level"] as! String
                        region.name = server["name"] as! String
                        region.fullName = server["nameFull"] as! String
                        region.ovHostname = server["ovHostname"] as! String
                        region.ovDefault = (server["ovDefault"] as! [String]).joined(separator: "\n")
                        region.ovNone = (server["ovNone"] as! [String]).joined(separator: "\n")
                        region.ovStrong = (server["ovStrong"] as! [String]).joined(separator: "\n")
                        region.ovStealth = (server["ovStealth"] as! [String]).joined(separator: "\n")
                        region.ipsecHostname = server["ipsecHostname"] as! String
                        region.ipsecDefault = (server["ipsecDefault"] as! [String]).joined(separator: "\n")
                        region.httpDefault = (server["httpDefault"] as! [String]).joined(separator: "\n")
                        region.socksDefault = (server["socksDefault"] as! [String]).joined(separator: "\n")
                        region.authorized = server["authorized"] as! Bool
                        region.country = server["country"] as! String
                        region.latitude = server["lat"] as! Double
                        region.longitude = server["lon"] as! Double
                        region.locDisplayScale = server["scale"] as! CGFloat
                        
                        if region.ipsecDefault == "" {
                            region.authorized = false
                        }
                        
                        if (server["default"] != nil) {
                            defaultRegion = region
                        }
                    } else {
                        let region = Region(
                            id: id as! String,
                            region: server["region"] as! String,
                            level: server["level"] as! String,
                            name: server["name"] as! String,
                            fullName: server["nameFull"] as! String,
                            ovHostname: server["ovHostname"] as! String,
                            ovDefault: (server["ovDefault"] as! [String]).joined(separator: "\n"),
                            ovNone: (server["ovNone"] as! [String]).joined(separator: "\n"),
                            ovStrong: (server["ovStrong"] as! [String]).joined(separator: "\n"),
                            ovStealth: (server["ovStealth"] as! [String]).joined(separator: "\n"),
                            ipsecHostname: server["ipsecHostname"] as! String,
                            ipsecDefault: (server["ipsecDefault"] as! [String]).joined(separator: "\n"),
                            httpDefault: (server["httpDefault"] as! [String]).joined(separator: "\n"),
                            socksDefault: (server["socksDefault"] as! [String]).joined(separator: "\n"),
                            country: server["country"] as! String,
                            authorized: server["authorized"] as! Bool,
                            latitude: server["lat"] as! Double,
                            longitude: server["lon"] as! Double,
                            locDisplayScale: server["scale"] as! CGFloat
                        )
                        realm.add(region, update: true)
                        
                        if (server["default"] != nil) {
                            defaultRegion = region
                        }
                    }
                    regionIds.append(id as! String)
                })
                
                let oldRegions = realm.objects(Region.self).filter("NOT (id IN %@)", regionIds)
                realm.delete(oldRegions)
                
                ConnectionHelper.checkLastConnectedServer(defaultRegion: defaultRegion)

                if !VPNConfigurationCoordinator.isConnected {
                    mainStore.state.regionState.serverPinger.updateLatencyForServers()
                }
                
                NotificationCenter.default.post(name: regionUpdateNotification, object: self)
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
    dynamic var region: String = ""
    dynamic var level: String = ""
    dynamic var name: String = ""
    dynamic var fullName: String = ""
    dynamic var ovHostname: String = ""
    dynamic var ovDefault: String = ""
    dynamic var ovNone: String = ""
    dynamic var ovStrong: String = ""
    dynamic var ovStealth: String = ""
    dynamic var ipsecHostname: String = ""
    dynamic var ipsecDefault: String = ""
    dynamic var httpDefault: String = ""
    dynamic var socksDefault: String = ""
    dynamic var country: String = ""
    dynamic var isFavorite: Bool = false
    dynamic var authorized: Bool = false
    dynamic var lastConnectedDate: Date = Date(timeIntervalSince1970: 1)
    dynamic var latencySeconds: Double = Double.infinity
    
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var locDisplayScale: CGFloat = 1.0
    
    init(id: String, region: String, level: String, name: String, fullName: String, ovHostname: String, ovDefault: String, ovNone: String, ovStrong: String, ovStealth: String, ipsecHostname: String, ipsecDefault: String, httpDefault: String, socksDefault: String, country: String, authorized: Bool, latitude: Double, longitude: Double, locDisplayScale: CGFloat) {

        super.init()
        
        self.id = id
        self.region = region
        self.level = level
        self.name = name
        self.fullName = fullName
        self.ovHostname = ovHostname
        self.ovDefault = ovDefault
        self.ovNone = ovNone
        self.ovStrong = ovStrong
        self.ovStealth = ovStealth
        self.ipsecDefault = ipsecDefault
        self.ipsecHostname = ipsecHostname
        self.httpDefault = httpDefault
        self.socksDefault = socksDefault
        self.country = country
        self.authorized = authorized
        self.isFavorite = false
        
        self.latitude = latitude
        self.longitude = longitude
        self.locDisplayScale = locDisplayScale

        if ipsecDefault == "" {
            self.authorized = false
        }
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
