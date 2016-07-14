//
//  RegionState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum RegionArea {
    case Americas
    case Europe
    case Asia
    case Pacific
    
    static var areas: [RegionArea] = [
        .Americas,
        .Europe,
        .Asia,
        .Pacific
    ]
    
    static var count: Int {
        return areas.count
    }
}

struct RegionState: StateType {
    let serverURL: String
    let selectedArea: RegionArea
}
