//
//  SettingsState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

import KeychainAccess

struct SettingsState: StateType {
    private let keychain = Keychain(service: "com.cyperpunk.ios.vpn.Settings")

    var connectWhenAppStarts: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.connectWhenAppStarts] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.connectWhenAppStarts] = String(newValue)
        }
    }
    var connectWhenWifiIsOn: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.connectWhenWifiIsOn] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.connectWhenWifiIsOn] = String(newValue)
        }
    }
    
    private struct SettingsStateKey {
        static let connectWhenAppStarts = "connectWhenAppStarts"
        static let connectWhenWifiIsOn = "connectWhenWifiIsOn"

    }
}
