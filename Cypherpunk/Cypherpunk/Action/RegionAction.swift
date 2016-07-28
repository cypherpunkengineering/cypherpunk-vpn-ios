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
    case ActiveAutoSelect
    case ChangeRegion(areaName: String, countryName: String, cityName: String, serverIP: String)
    case Connect
}