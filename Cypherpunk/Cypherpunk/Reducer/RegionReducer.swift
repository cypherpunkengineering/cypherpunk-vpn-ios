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

    typealias ReducerStateType = RegionState
    
    func handleAction(action: Action, state: RegionState?) -> RegionState {
        
        var regionState = state ?? RegionState(
            name:  "",
            serverIP: "",
            countryCode: ""
        )
        
        if let action = action as? RegionAction {
            switch action {
            case .changeRegion(let name, let serverIP, let countryCode):
                regionState.name = name
                regionState.serverIP = serverIP
                regionState.countryCode = countryCode
            case .connect:
                break
            }
        }
        
        return regionState
    }
    
}

