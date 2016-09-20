//
//  AppReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/17.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct AppReducer: Reducer {
    
    let accountReducer = AccountReducer()
    let regionReducer = RegionReducer()
    let settingsReducer = SettingsReducer()
    let themeReducer = ThemeReducer()
    let statusReducer = StatusReducer()
    
    func handleAction(_ action: Action, state: AppState?) -> AppState {
        
        if let action = action as? AccountAction {
            if case AccountAction.logout = action {
                return AppState(
                    accountState: accountReducer.handleAction(action, state: nil),
                    regionState:  regionReducer.handleAction(action, state: nil),
                    settingsState: settingsReducer.handleAction(action, state: nil),
                    themeState: themeReducer.handleAction(action, state: nil),
                    statusState:  statusReducer.handleAction(action, state: nil)
                )
            }
        }
        return AppState(
            accountState: accountReducer.handleAction(action, state: state?.accountState),
            regionState:  regionReducer.handleAction(action, state: state?.regionState),
            settingsState: settingsReducer.handleAction(action, state: state?.settingsState),
            themeState: themeReducer.handleAction(action, state: state?.themeState),
            statusState:  statusReducer.handleAction(action, state: state?.statusState)
        )
    }
}
