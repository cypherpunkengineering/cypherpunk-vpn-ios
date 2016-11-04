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
    case IPSec = 1
    case IKEv2 = 2
    
    var description: String {
        switch self {
        case .IPSec:
            return "IPSec"
        case .IKEv2:
            return "IKEv2"
        }
    }

}

extension Keychain {
    static func userKeychain() -> Keychain {
        return Keychain(service: mainStore.state.accountState.mailAddress ?? "com.cyperpunk.ios.vpn.Settings")
    }
    static func inAppKeychain() -> Keychain {
        return Keychain(service: "com.cyperpunk.ios.vpn.keychain")
    }
}

struct SettingsState: StateType {

    var isAutoConnectOnBoot: Bool {
        get{
            if mainStore.state.isInstalledPreferences == false {
                return false
            }
            
            let keychain = Keychain.userKeychain()
            return NSString(string: keychain[SettingsStateKey.isAutoConnectOnBoot] ?? "false").boolValue
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain[SettingsStateKey.isAutoConnectOnBoot] = String(newValue)
        }
    }
    
    var isAutoReconnect: Bool {
        get{
            if mainStore.state.isInstalledPreferences == false {
                return false
            }
            
            let keychain = Keychain.userKeychain()
            return NSString(string: keychain[SettingsStateKey.isAutoReconnect] ?? "false").boolValue
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain[SettingsStateKey.isAutoReconnect] = String(newValue)
        }
    }
    
    
    /* VPN Settings */
    var vpnProtocolMode: VPNProtocolMode {
        get {
            
            if mainStore.state.isInstalledPreferences == false {
                return .IKEv2
            }

            let keychain = Keychain.userKeychain()
            let value: Int = NSString(string: keychain[SettingsStateKey.vpnProtocolMode] ?? "2").integerValue
            return VPNProtocolMode(rawValue: value) ?? .IKEv2
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain[SettingsStateKey.vpnProtocolMode] = String(newValue.rawValue)
        }
    }
    
    var isAutoSecureConnectionsWhenConnectedUntrustedNetwork: Bool {
        get{
            let keychain = Keychain.userKeychain()
            return NSString(string: keychain[SettingsStateKey.isAutoSecureConnectionsWhenConnectedUntrustedNetwork] ?? "true").boolValue
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain[SettingsStateKey.isAutoSecureConnectionsWhenConnectedUntrustedNetwork] = String(newValue)
        }

    }

    var isAutoSecureConnectionsWhenConnectedOtherNetwork: Bool {
        get{
            let keychain = Keychain.userKeychain()
            return NSString(string: keychain[SettingsStateKey.isAutoSecureConnectionsWhenConnectedOtherNetwork] ?? "true").boolValue
        }
        set(newValue) {
            let keychain = Keychain.userKeychain()
            keychain[SettingsStateKey.isAutoSecureConnectionsWhenConnectedOtherNetwork] = String(newValue)
        }
        
    }
    


    fileprivate struct SettingsStateKey {
        static let isAutoConnectOnBoot = "isAutoConnectOnBoot"
        static let isAutoReconnect = "isAutoReconnect"
        static let vpnProtocolMode = "vpnProtocolMode"
        static let isAutoSecureConnectionsWhenConnectedUntrustedNetwork = "isAutoSecureConnectionsWhenConnectedUntrustedNetwork"
        static let isAutoSecureConnectionsWhenConnectedOtherNetwork = "isAutoSecureConnectionsWhenConnectedOtherNetwork"
    }
}
