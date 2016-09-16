//
//  StatusState.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct StatusState: StateType {
    var originalIPAddress: String?
    var newIPAddress: String?
    
    var originalLongitude: Double? = nil
    var originalLatitude: Double? = nil
    var newLongitude: Double? = nil
    var newLatitude: Double? = nil
    
    var originalCountry: String? = nil
    var newCountry: String? = nil
    
    var connectedDate: NSDate?
}