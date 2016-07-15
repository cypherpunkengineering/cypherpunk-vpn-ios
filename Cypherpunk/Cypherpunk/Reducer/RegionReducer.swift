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
        
        let regionState = state ?? RegionState(serverURL: "", selectedArea: .Americas)
        
        return regionState
    }
    
}

