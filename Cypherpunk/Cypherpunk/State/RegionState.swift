//
//  RegionState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct RegionState: StateType {
    var name: String
    var serverIP: String
    
    var recentryConnected: [RegionHistory] = []
    
    var title: String {
        return name
    }
    
}

struct RegionHistory {
    var name: String
    var serverIP: String
    
    init(state: RegionState) {
        self.name = state.name
        self.serverIP = state.serverIP
    }
    
    var title: String {
        return name
    }

}

extension RegionHistory: Equatable {
}

func ==(lhs: RegionHistory, rhs:RegionHistory) -> Bool {
    return lhs.name == rhs.name
}
