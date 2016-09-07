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
            case .vpnProtocolMode(let value):
                state.vpnProtocolMode = value
            }
            VPNConfigurationCoordinator.start{
                
            }
        }
        return state
    }
}