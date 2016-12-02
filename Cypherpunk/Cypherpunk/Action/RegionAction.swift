//
//  RegionAction.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

enum RegionAction: Action {
    case setup
    case changeRegion(regionId: String, name: String, serverIP: String, countryCode: String, remoteIdentifier: String, level: String)
    case connect
}
