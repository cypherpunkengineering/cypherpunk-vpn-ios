//
//  RegionReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift
import RealmSwift


struct RegionReducer {

    typealias ReducerStateType = RegionState
    
    func handleAction(action: Action, state: RegionState?) -> RegionState {
        
        var regionState = state ?? RegionState(
            regionId: "",
            name:  "",
            fullName: "",
            serverIP: "",
            countryCode: "",
            remoteIdentifier: "",
            level: ""
        )
        
        if let action = action as? RegionAction {
            switch action {
            case .setup:
                
                let realm = try! Realm()
                var target: Region? = nil
                if let regionId = mainStore.state.regionState.lastSelectedRegionId, let region = realm.object(ofType: Region.self, forPrimaryKey: regionId), region.authorized == true {
                    target = region
                } else {
                    let sortProperties = [
                        SortDescriptor(keyPath: "country", ascending: true),
                        SortDescriptor(keyPath: "name", ascending: true)
                    ]
                    
                    if let region = realm.objects(Region.self).filter("isFavorite == true AND authorized == true").sorted(byKeyPath: "lastConnectedDate", ascending: false).first {
                        target = region
                    } else if let region = realm.objects(Region.self).filter("isFavorite == false AND authorized == true AND lastConnectedDate != %@", Date(timeIntervalSince1970: 1)).sorted(byKeyPath: "lastConnectedDate", ascending: false).first {
                        target = region
                    } else {
                        LocationSection.regions.flatMap{return $0.regionCode}.forEach({ (regionCode) in
                            if target != nil { return }
                            if let region = realm.objects(Region.self).filter("region == %@ AND authorized == true", regionCode).sorted(by:sortProperties).first {
                                target = region
                            }
                        })
                    }
                }
                
                if let region = target {
                    regionState.regionId = region.id
                    regionState.name = region.name
                    regionState.fullName = region.fullName
                    regionState.serverIP = region.ipsecDefault.components(separatedBy: "\n")[0]
                    regionState.countryCode = region.country
                    regionState.remoteIdentifier = region.ipsecHostname
                    regionState.lastSelectedRegionId = region.id
                    regionState.level = region.level
                }
            case .changeRegion(let regionId, let name, let fullName, let serverIP, let countryCode, let remoteidentifier, let level, let cypherplayOn):
                regionState.regionId = regionId
                regionState.name = name
                regionState.fullName = fullName
                regionState.serverIP = serverIP.components(separatedBy: "\n")[0]
                regionState.countryCode = countryCode
                regionState.remoteIdentifier = remoteidentifier
                regionState.lastSelectedRegionId = regionId
                regionState.level = level
                regionState.cypherplayOn = cypherplayOn
            case .connect:
                let realm = try! Realm()
                if let region = realm.object(ofType: Region.self, forPrimaryKey: regionState.regionId) {
                    try! realm.write {
                        region.lastConnectedDate = Date()
                    }
                }
                break
            }
        }
        
        return regionState
    }
    
}

