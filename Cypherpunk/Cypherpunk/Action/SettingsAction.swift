//
//  SettingsAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

enum SettingsAction: Action {
    case ConnectWhenAppStarts(isOn: Bool)
    case ConnectWhenWifiIsOn(isOn: Bool)
}