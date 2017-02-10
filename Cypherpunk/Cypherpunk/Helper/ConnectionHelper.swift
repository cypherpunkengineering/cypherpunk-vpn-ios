//
//  ConnectionHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/9/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import NetworkExtension

class ConnectionHelper {
    static func connectTo(region: Region) {
        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.name, serverIP: region.ipsecHostname, countryCode: region.country, remoteIdentifier: region.ipsecHostname, level: region.level))
        
        // TODO: I don't think this logic is what is desired, will revisit once other issues are addressed
        let isConnected = VPNConfigurationCoordinator.isConnected
        VPNConfigurationCoordinator.start {
            let manager = NEVPNManager.shared()
            if isConnected, manager.isOnDemandEnabled == false {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
                    VPNConfigurationCoordinator.connect()
                })
            }
        }
    }
}

