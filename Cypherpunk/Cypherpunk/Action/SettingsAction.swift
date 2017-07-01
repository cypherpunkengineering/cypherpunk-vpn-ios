//
//  SettingsAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift
import NetworkExtension

enum SettingsAction: Action {
    case vpnProtocolMode(value: VPNProtocolMode)
    case isTrustCellularNetworks(isOn: Bool)
    case isAutoSecureConnectionsWhenConnectedUntrustedNetwork(isOn: Bool)
    case isAutoSecureConnectionsWhenConnectedOtherNetwork(isOn: Bool)
    case blockAds(block: Bool)
    case blockMalware(block: Bool)
    case cypherplayOn(isOn: Bool)
    case alwaysOn(isOn: Bool)
}
