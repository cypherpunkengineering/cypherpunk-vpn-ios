//
//  AppReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/17.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

let appReducer = AppReducer()
struct AppReducer {
    typealias ReducerStateType = AppState

    let accountReducer = AccountReducer()
    let regionReducer = RegionReducer()
    let settingsReducer = SettingsReducer()
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        if let action = action as? AccountAction {
            switch action {
            case .logout:
                let standard = UserDefaults.standard
                standard.set(false, forKey: "isInstalledPreferences")
                standard.synchronize()
                return AppState(
                    accountState: accountReducer.handleAction(action: action, state: nil),
                    regionState:  regionReducer.handleAction(action: action, state: nil),
                    settingsState: settingsReducer.handleAction(action: action, state: nil)
                )
            default:
                break
            }
        }
        
        if let action = action as? AppAction {
            switch action {
            case .VPNInstalled:
                let standard = UserDefaults.standard
                standard.set(true, forKey: "isInstalledPreferences")
                standard.synchronize()
            }
        }
        
        return AppState(
            accountState: accountReducer.handleAction(action: action, state: state?.accountState ?? AccountState.restore()),
            regionState:  regionReducer.handleAction(action: action, state: state?.regionState),
            settingsState: settingsReducer.handleAction(action: action, state: state?.settingsState)
        )
    }
}
