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
    func handleAction(_ action: Action, state: RegionState?) -> RegionState {
        
        var regionState = state ?? RegionState(
            name:  "",
            serverIP: "",
            recentryConnected: [])
        
        if let action = action as? RegionAction {
            switch action {
            case .ChangeRegion(let name, let serverIP):
                regionState.name = name
                regionState.serverIP = serverIP
            case .Connect:
                let history = RegionHistory(state: regionState)
                
                if let index = regionState.recentryConnected.index(of: history) {
                    regionState.recentryConnected.remove(at: index)
                }
                
                if regionState.recentryConnected.count >= 3 {
                    regionState.recentryConnected.removeLast()
                }
                
                regionState.recentryConnected.insert(history, at: 0)
            }
        }
        
        return regionState
    }
    
}

