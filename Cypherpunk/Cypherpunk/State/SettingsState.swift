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
import NetworkExtension

enum VPNProtocolMode: Int {
    case ipSec = 1
    case ikEv2 = 2
    
    var description: String {
        switch self {
        case .ipSec:
            return "IPSec"
        case .ikEv2:
            return "IKEv2"
        }
    }

}

struct SettingsState: StateType {
    fileprivate let keychain = Keychain(service: "com.cyperpunk.ios.vpn.Settings")

    
    var isAutoReconnect: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.isAutoReconnect] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isAutoReconnect] = String(newValue)
        }
    }
    
    
    /* VPN Settings */
    var vpnProtocolMode: VPNProtocolMode {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.vpnProtocolMode] ?? "2").integerValue
            return VPNProtocolMode(rawValue: value) ?? .ikEv2
        }
        set(newValue) {
            keychain[SettingsStateKey.vpnProtocolMode] = String(newValue.rawValue)
        }
    }

    fileprivate struct SettingsStateKey {
        static let isAutoReconnect = "isAutoReconnect"
        static let vpnProtocolMode = "vpnProtocolMode"
    }
}
