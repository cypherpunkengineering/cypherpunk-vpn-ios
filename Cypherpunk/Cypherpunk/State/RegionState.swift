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
    
    var title: String {
        return name
    }
    
}
