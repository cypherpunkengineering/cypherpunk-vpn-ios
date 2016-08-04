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
            case .cypherpunkMode(let isOn):
                state.cypherpunkMode = isOn
            case .protectOnDeviceStartup(let isOn):
                state.protectOnDeviceStartup = isOn
            case .protectOnUntrustedNetworks(let isOn):
                state.protectOnUntrustedNetworks = isOn
            case .encryption(let value):
                state.encryption = value
            case .authenitication(let value):
                state.authenitication = value
            case .handshake(let value):
                if #available(iOS 8.3, *) {
                    state.handshake = value
                }
            }
        }
        return state
    }
}