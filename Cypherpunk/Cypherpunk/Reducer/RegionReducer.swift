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


struct RegionReducer: Reducer {

    typealias ReducerStateType = RegionState
    
    func handleAction(action: Action, state: RegionState?) -> RegionState {
        
        var regionState = state ?? RegionState(
            regionId: "",
            name:  "",
            serverIP: "",
            countryCode: "",
            remoteIdentifier: ""
        )
        
        if let action = action as? RegionAction {
            switch action {
            case .changeRegion(let regionId, let name, let serverIP, let countryCode, let remoteidentifier):
                regionState.regionId = regionId
                regionState.name = name
                regionState.serverIP = serverIP
                regionState.countryCode = countryCode
                regionState.remoteIdentifier = remoteidentifier
                regionState.lastSelectedRegionId = regionId
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

