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
    
    let loginReducer = LoginReducer()
    let regionReducer = RegionReducer()
    let settingsReducer = SettingsReducer()
    let themeReducer = ThemeReducer()
    let statusReducer = StatusReducer()
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        return AppState(
            loginState: loginReducer.handleAction(action, state: state?.loginState),
            regionState:  regionReducer.handleAction(action, state: state?.regionState),
            settingsState: settingsReducer.handleAction(action, state: state?.settingsState),
            themeState: themeReducer.handleAction(action, state: state?.themeState),
            statusState:  statusReducer.handleAction(action, state: state?.statusState)
        )
    }
}