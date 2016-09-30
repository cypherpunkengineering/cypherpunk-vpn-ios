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
    typealias ReducerStateType = AppState

    let accountReducer = AccountReducer()
    let regionReducer = RegionReducer()
    let settingsReducer = SettingsReducer()
    let statusReducer = StatusReducer()
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        if let action = action as? AccountAction {
            if case AccountAction.logout = action {
                return AppState(
                    accountState: accountReducer.handleAction(action: action, state: nil),
                    regionState:  regionReducer.handleAction(action: action, state: nil),
                    settingsState: settingsReducer.handleAction(action: action, state: nil),
                    statusState:  statusReducer.handleAction(action: action, state: nil)
                )
            }
        }
        return AppState(
            accountState: accountReducer.handleAction(action: action, state: state?.accountState ?? AccountState.restore()),
            regionState:  regionReducer.handleAction(action: action, state: state?.regionState),
            settingsState: settingsReducer.handleAction(action: action, state: state?.settingsState),
            statusState:  statusReducer.handleAction(action: action, state: state?.statusState)
        )
    }
}
