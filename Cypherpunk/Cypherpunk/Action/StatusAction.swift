//
//  StatusAction.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum StatusAction: Action {
    case getOriginalIPAddress(address: String)
    case getNewIPAddress(address: String)
    case getOriginalGeoLocation(response: GeoLocationResponse)
    case getNewGeoLocation(response: GeoLocationResponse)

    case setConnectedDate(date: Date?)
}
