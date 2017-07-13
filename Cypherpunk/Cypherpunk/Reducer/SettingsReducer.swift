 //
//  SettingsReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift
import NetworkExtension
 
struct SettingsReducer {
    typealias ReducerStateType = SettingsState
    
    func handleAction(action: Action, state: SettingsState?) -> SettingsState {
        var state = state ?? SettingsState()
        
        if let action = action as? SettingsAction {
            var suppressReconnectDialog = false
            
            switch action {
            case .vpnProtocolMode(let value):
                state.vpnProtocolMode = value
            case .isTrustCellularNetworks(let isOn):
                state.isTrustCellularNetworks = isOn
            case .isAutoSecureConnectionsWhenConnectedUntrustedNetwork(let isOn):
                state.isAutoSecureConnectionsWhenConnectedUntrustedNetwork = isOn
            case .isAutoSecureConnectionsWhenConnectedOtherNetwork(let isOn):
                state.isAutoSecureConnectionsWhenConnectedOtherNetwork = isOn
            case .blockAds(let block):
                state.blockAds = block
            case .blockMalware(let block):
                state.blockMalware = block
            case .cypherplayOn(let isOn):
                state.cypherplayOn = isOn
                // do not show user the dialog if we are changing cypherplay setting
                suppressReconnectDialog = true
            case .alwaysOn(let isOn):
                state.alwaysOn = isOn
            }
            
            let isConnected = VPNConfigurationCoordinator.isConnected
            VPNConfigurationCoordinator.start{
                let manager = NEVPNManager.shared()
                if isConnected, manager.isOnDemandEnabled == false, !suppressReconnectDialog {
                    DispatchQueue.main.async {
                        ReconnectDialogView.show()
                    }
                }
                if isConnected {
                    VPNConfigurationCoordinator.connect()
                }
            }
        }
        return state
    }
}
