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
    var areaName: String
    var countryName: String
    var cityName: String
    var serverIP: String
    
    var isAutoSelect: Bool = true
    
    var recentryConnected: [RegionHistory] = []
    
    var title: String {
        if isAutoSelect {
            return "Auto Region Select"
        } else {
            return countryName
        }
    }
    
}

struct RegionHistory {
    var areaName: String
    var countryName: String
    var cityName: String
    var serverIP: String
    
    init(state: RegionState) {
        self.areaName = state.areaName
        self.countryName = state.countryName
        self.cityName = state.cityName
        self.serverIP = state.serverIP
    }
    
    var title: String {
        return cityName + ", " + countryName
    }

}

extension RegionHistory: Equatable {
}


func ==(lhs: RegionHistory, rhs:RegionHistory) -> Bool {
    return lhs.areaName == rhs.areaName &&
    lhs.countryName == rhs.countryName &&
    lhs.cityName == rhs.cityName &&
    lhs.serverIP == rhs.serverIP
}
