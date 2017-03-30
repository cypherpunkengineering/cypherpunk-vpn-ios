//
//  VPNServerOption.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/17/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//


enum VPNServerOptionType: String {
    case CypherPlay
    case Fastest
    case FastestUS
    case FastestUK
    case Server
    case Location1
    case Location2
}

class VPNServerOption : Equatable {
    private var findServer: (String?) -> Region?
    var type: VPNServerOptionType
    var country: String?
    var cypherplay = false
    
    init(findServer: @escaping (String?) -> Region?, type: VPNServerOptionType) {
        self.findServer = findServer
        self.type = type
    }

    convenience init(findServer: @escaping (String?) -> Region?, type: VPNServerOptionType, country: String?) {
        self.init(findServer: findServer, type: type)
        self.country = country
    }
    
    func connect() {
        if let region = findServer(country) {
            ConnectionHelper.connectTo(region: region, cypherplay: cypherplay)
        }
    }
    
    static func ==(lhs: VPNServerOption, rhs: VPNServerOption) -> Bool {
        return lhs.findServer(lhs.country) == rhs.findServer(rhs.country) && lhs.type == rhs.type
    }
    
    func getServer() -> Region? {
        return findServer(country)
    }
}
