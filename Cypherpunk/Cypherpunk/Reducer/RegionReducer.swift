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
        
        var regionState = state ?? RegionState(cityName: "", serverIP: "")
        
        if let action = action as? RegionAction {
            switch action {
            case .ChangeRegion(let cityName, let serverIP):
                regionState.cityName = cityName
                regionState.serverIP = serverIP
            }
        }
        
        return regionState
    }
    
}

