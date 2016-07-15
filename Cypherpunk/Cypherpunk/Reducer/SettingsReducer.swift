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
            case .ConnectWhenAppStarts(let isOn):
                state.connectWhenAppStarts = isOn
            case .ConnectWhenWifiIsOn(let isOn):
                state.connectWhenWifiIsOn = isOn
            }
        }
        return state
    }
}