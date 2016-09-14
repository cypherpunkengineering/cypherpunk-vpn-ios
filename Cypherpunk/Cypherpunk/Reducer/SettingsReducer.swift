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
 
struct SettingsReducer: Reducer {
    func handleAction(action: Action, state: SettingsState?) -> SettingsState {
        var state = state ?? SettingsState()
        
        if let action = action as? SettingsAction {
            switch action {
            case .isAutoReconnect(let isOn):
                state.isAutoReconnect = isOn
            case .vpnProtocolMode(let value):
                state.vpnProtocolMode = value
            }
            let manager = NEVPNManager.sharedManager()
            let isConnected = manager.connection.status == .Connected

            VPNConfigurationCoordinator.start{
                if state.isAutoReconnect && isConnected {
                    try! VPNConfigurationCoordinator.connect()
                }
            }
        }
        return state
    }
}