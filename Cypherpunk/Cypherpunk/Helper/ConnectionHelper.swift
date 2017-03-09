//
//  ConnectionHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/9/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import NetworkExtension
import RealmSwift

class ConnectionHelper {
    static func connectTo(region: Region, cypherplay: Bool) {
         mainStore.dispatch(SettingsAction.cypherplayOn(isOn: cypherplay))
        
        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.name, serverIP: region.ipsecHostname, countryCode: region.country, remoteIdentifier: region.ipsecHostname, level: region.level))
        
        // TODO: I don't think this logic is what is desired, will revisit once other issues are addressed
//        let isConnected = VPNConfigurationCoordinator.isConnected
        VPNConfigurationCoordinator.start {
//            let manager = NEVPNManager.shared()
//            if isConnected, manager.isOnDemandEnabled == false {
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
//                    VPNConfigurationCoordinator.connect()
//                })
//            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
                VPNConfigurationCoordinator.connect()
            })
        }
    }
    
    static func connectToFastest(cypherplay: Bool) {
        var region: Region? = nil
        
        let predicates = baseRegionQueryPredicates()
        
        let realm = try! Realm()
        let regions = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds")
        
        region = regions.first
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: cypherplay)
        }
    }
    
    static func connectToFastestUS() {
        var region: Region? = nil
        
        var predicates = baseRegionQueryPredicates()
        // fastest US will restrict query to servers that have country set to US
        predicates.append(NSPredicate(format: "country = 'US'"))
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds").first
        
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: false)
        }
    }
    
    static func connectToFastestUK() {
        var region: Region? = nil
        
        var predicates = baseRegionQueryPredicates()
        // fastest UK will restrict query to servers that have country set to GB
        predicates.append(NSPredicate(format: "country = 'GB'"))
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds").first
        
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: false)
        }
    }
    
    static func baseRegionQueryPredicates() -> [NSPredicate] {
        var predicates = [NSPredicate]()
        
        /**
         * All queries will do the following:
         * 1) Check that authorized is set to true
         * 2) Exclude any servers that developer servers
         */
        
        predicates.append(NSPredicate(format: "authorized == true"))
        predicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "level == 'developer'")))
        
        return predicates
    }
}

