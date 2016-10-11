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
    let accountState: AccountState
    let regionState: RegionState
    let settingsState: SettingsState
    let statusState: StatusState
    
    var isInstalledPreferences: Bool {
        get {
            let standard = UserDefaults.standard
            return standard.bool(forKey: "isInstalledPreferences")
        }
        set(value) {
            let standard = UserDefaults.standard
            standard.set(value, forKey: "isInstalledPreferences")
        }
    }

    static func getSharedState() -> AppState {
        return mainStore.state
    }
}
