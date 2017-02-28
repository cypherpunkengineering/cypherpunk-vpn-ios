//
//  RegionState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

import KeychainAccess

struct RegionState: StateType {
    var regionId: String
    var name: String
    var serverIP: String
    var countryCode: String
    var remoteIdentifier: String
    var level: String
    let serverPinger = ServerPinger()
    
    var title: String {
        return name
    }
    
    var lastSelectedRegionId: String? {
        get {
            let keychain = Keychain.userKeychain()
            return keychain["lastSelectedRegionId"]
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain["lastSelectedRegionId"] = newValue
        }
    }
}
