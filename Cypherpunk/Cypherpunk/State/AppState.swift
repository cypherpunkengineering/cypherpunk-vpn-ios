//
//  AppState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/17.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct AppState: StateType {
    let loginState: LoginState
    let regionState: RegionState
    let settingsState: SettingsState
    let themeState: ThemeState
    let statusState: StatusState
    
    static func getSharedState() -> AppState {
        return mainStore.state
    }
}