 //
//  SettingsReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

struct SettingsReducer: Reducer {
    func handleAction(action: Action, state: SettingsState?) -> SettingsState {
        var state = state ?? SettingsState()
        
        if let action = action as? SettingsAction {
            switch action {
            case .isAutoReconnect(let isOn):
                state.isAutoReconnect = isOn
            case .isAutoConnectOnBoot(let isOn):
                state.isAutoConnectOnBoot = isOn
            case .isAutoConnectVPNOnUntrusted(let isOn):
                state.isAutoConnectVPNOnUntrusted = isOn
            case .isTrustCellularNetworks(let isOn):
                state.isTrustCellularNetworks = isOn
            case .isBlockLocalNetwork(let isOn):
                state.isBlockLocalNetwork = isOn
            case .isKillSwitch(let isOn):
                state.isKillSwitch = isOn
            case .vpnProtocolMode(let value):
                state.vpnProtocolMode = value
            case .remotePort(let value):
                state.remotePort = value
            case .isUseSmallPackets(let isOn):
                state.isUseSmallPackets = isOn
            case .encryption(let value):
                state.encryption = value
            case .authenitication(let value):
                state.authenitication = value
            case .handshake(let value):
                if #available(iOS 8.3, *) {
                    state.handshake = value
                }
            }
            VPNConfigurationCoordinator.start{
                
            }
        }
        return state
    }
}