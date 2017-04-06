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
        
    static func findFastest(_ country: String? = nil) -> Region? {
        var region: Region? = nil
        
        var predicates = baseRegionQueryPredicates()
        
        // check if a country was provided, if so restrict the query by it
        if let unwrappedCountry = country {
            predicates.append(NSPredicate(format: "country = '\(unwrappedCountry)'"))
        }
        
        let realm = try! Realm()
        let regions = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds")
        
        region = regions.first
        return region
    }
    
    static func connectToFastest(cypherplay: Bool, country: String? = nil) {
        if let region = findFastest(country) {
            ConnectionHelper.connectTo(region: region, cypherplay: cypherplay)
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
    
    static func getUserLocations(count: Int) -> [Region] {
        var regions = [Region]()
        
        let realm = try! Realm()
        let favorites = realm.objects(Region.self).filter("isFavorite = true").sorted(byKeyPath: "lastConnectedDate", ascending: false)
        
        // check for favorites
        for favorite in favorites {
            if regions.count < count {
                regions.append(favorite)
            }
            else {
                break
            }
        }
        
        let notFavoritePredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "isFavorite = true"))
        let notDeveloperPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "level = 'developer'"))
        let authorizedPredicate = NSPredicate(format: "authorized = true")
        
        // check for recently connected
        if regions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "lastConnectedDate = %@", Date(timeIntervalSince1970: 1) as CVarArg)))
            predicates.append(notDeveloperPredicate)
            
            let recent = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "lastConnectedDate", ascending: false)
            
            for region in recent {
                if regions.count < count {
                    regions.append(region)
                }
                else {
                    break
                }
            }
        }
        
        // if there weren't enough recently connected or favorites, just find closest servers
        if regions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(notDeveloperPredicate)
            predicates.append(authorizedPredicate)
            
            // exclude the regions already added
            let regionIds = regions.map({ (region) -> String in
                region.id
            })
            predicates.append(NSPredicate(format: "NOT id IN %@", regionIds))
            
            let closest = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
            
            for region in closest {
                if regions.count < count {
                    regions.append(region)
                }
                else {
                    break
                }
            }
        }
        return regions
    }
}

