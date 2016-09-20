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
    typealias ReducerStateType = SettingsState
    
    func handleAction(action: Action, state: SettingsState?) -> SettingsState {
        var state = state ?? SettingsState()
        
        if let action = action as? SettingsAction {
            switch action {
            case .isAutoReconnect(let isOn):
                state.isAutoReconnect = isOn
            case .vpnProtocolMode(let value):
                state.vpnProtocolMode = value
            }
            let manager = NEVPNManager.shared()
            let isConnected = manager.connection.status == .connected

            VPNConfigurationCoordinator.start{
                if state.isAutoReconnect && isConnected {
                    try! VPNConfigurationCoordinator.connect()
                }
            }
        }
        return state
    }
}
