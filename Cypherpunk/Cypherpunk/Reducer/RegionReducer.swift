//
//  RegionReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct RegionReducer: Reducer {
    func handleAction(action: Action, state: RegionState?) -> RegionState {
        
        var regionState = state ?? RegionState(
            areaName: AreaIPAddress.Tokyo1.areaName,
            countryName: AreaIPAddress.Tokyo1.countryName,
            cityName: AreaIPAddress.Tokyo1.cityName,
            serverIP: AreaIPAddress.Tokyo1.IPAddress,
            isAutoSelect: false,
            recentryConnected: [])
        
        if let action = action as? RegionAction {
            switch action {
            case .ActiveAutoSelect:
                regionState.isAutoSelect = true
                regionState.areaName = ""
                regionState.countryName = ""
                regionState.cityName = ""
                regionState.serverIP = ""
            case .ChangeRegion(let areaName, let countryName, let cityName, let serverIP):
                regionState.areaName = areaName
                regionState.countryName = countryName
                regionState.cityName = cityName
                regionState.serverIP = serverIP
                regionState.isAutoSelect = false
            case .Connect:
                if regionState.isAutoSelect == false {
                    let history = RegionHistory(state: regionState)
                    
                    if let index = regionState.recentryConnected.indexOf(history) {
                        regionState.recentryConnected.removeAtIndex(index)
                    }
                    
                    if regionState.recentryConnected.count >= 3 {
                        regionState.recentryConnected.removeLast()
                    }
                    
                    regionState.recentryConnected.insert(history, atIndex: 0)
                    
                }
            }
        }
        
        return regionState
    }
    
}

