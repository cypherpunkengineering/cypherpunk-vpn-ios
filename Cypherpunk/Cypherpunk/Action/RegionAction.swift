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
    case changeRegion(name: String, serverIP: String, countryCode: String)
    case connect
}
