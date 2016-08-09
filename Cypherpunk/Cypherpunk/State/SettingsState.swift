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

extension NEVPNIKEv2EncryptionAlgorithm {
    public var description: String {
        switch self {
        case .AlgorithmDES:
            return "DES"
        case .Algorithm3DES:
            return "3DES"
        case .AlgorithmAES128:
            return "AES128"
        case .AlgorithmAES128GCM:
            return "AES128GCM"
        case .AlgorithmAES256:
            return "AES256"
        case .AlgorithmAES256GCM:
            return "AES256GCM"
        }
    }
}

extension NEVPNIKEv2IntegrityAlgorithm {
    public var description: String {
        switch  self {
        case .SHA96:
            return "SHA96"
        case .SHA160:
            return "SHA160"
        case .SHA256:
            return "SHA256"
        case .SHA384:
            return "SHA384"
        case .SHA512:
            return "SHA512"
        }
    }
}

@available(iOS 8.3, *)
extension NEVPNIKEv2CertificateType {
    public var description: String {
        switch self {
        case .RSA:
            return "RSA"
        case .ECDSA256:
            return "ECDSA256"
        case .ECDSA384:
            return "ECDSA384"
        case .ECDSA521:
            return "ECDSA512"
        }
    }
}

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

enum RemotePort: Int {
    case Auto = 1

    var description: String {
        switch self {
        case .Auto:
            return "Auto"
        }
    }

}

struct SettingsState: StateType {
    private let keychain = Keychain(service: "com.cyperpunk.ios.vpn.Settings")

    
    var isAutoReconnect: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.isAutoReconnect] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isAutoReconnect] = String(newValue)
        }
    }
    
    
    var isAutoConnectOnBoot: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.isAutoConnectOnBoot] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isAutoConnectOnBoot] = String(newValue)
        }
    }
    
    var isAutoConnectVPNOnUntrusted: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.isAutoConnectVPNOnUntrusted] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isAutoConnectVPNOnUntrusted] = String(newValue)
        }
    }

    var isTrustCellularNetworks: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.isTrustCellularNetworks] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isTrustCellularNetworks] = String(newValue)
        }
    }

    var isBlockLocalNetwork: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.isBlockLocalNetwork] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isBlockLocalNetwork] = String(newValue)
        }
    }

    var isKillSwitch: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.isKillSwitch] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isKillSwitch] = String(newValue)
        }
    }

    
    /* VPN Settings */
    var vpnProtocolMode: VPNProtocolMode {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.vpnProtocolMode] ?? "2").integerValue
            return VPNProtocolMode(rawValue: value) ?? .IKEv2
        }
        set(newValue) {
            keychain[SettingsStateKey.vpnProtocolMode] = String(newValue.rawValue)
        }
    }

    var remotePort: RemotePort {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.remotePort] ?? "1").integerValue
            return RemotePort(rawValue: value) ?? .Auto
        }
        set(newValue) {
            keychain[SettingsStateKey.remotePort] = String(newValue.rawValue)
        }
    }

    var isUseSmallPackets: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.isUseSmallPackets] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.isUseSmallPackets] = String(newValue)
        }
    }
    

    
    var encryption: NEVPNIKEv2EncryptionAlgorithm {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.encryption] ?? "1").integerValue
            return NEVPNIKEv2EncryptionAlgorithm(rawValue: value) ?? .AlgorithmDES
        }
        set(newValue) {
            keychain[SettingsStateKey.encryption] = String(newValue.rawValue)
        }
    }

    var authenitication: NEVPNIKEv2IntegrityAlgorithm {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.authenitication] ?? "3").integerValue
            return NEVPNIKEv2IntegrityAlgorithm(rawValue: value) ?? .SHA256
        }
        set(newValue) {
            keychain[SettingsStateKey.authenitication] = String(newValue.rawValue)
        }
    }

    @available(iOS 8.3, *)
    var handshake: NEVPNIKEv2CertificateType {
        get {
            let value: Int = NSString(string: keychain[SettingsStateKey.handshake] ?? "1").integerValue
            return NEVPNIKEv2CertificateType(rawValue: value) ?? .RSA
        }
        set(newValue) {
            keychain[SettingsStateKey.handshake] = String(newValue.rawValue)
        }
    }
    
    private struct SettingsStateKey {
        static let encryption = "encryption"
        static let authenitication = "authenitication"
        static let handshake = "handshake"
        
        static let isAutoReconnect = "isAutoReconnect"
        static let isAutoConnectOnBoot = "isAutoConnectOnBoot"
        static let isAutoConnectVPNOnUntrusted = "isAutoConnectVPNOnUntrusted"
        static let isTrustCellularNetworks = "isTrustCellularNetworks"
        static let isBlockLocalNetwork = "isBlockLocalNetwork"
        static let isKillSwitch = "isKillSwitch"
        
        static let vpnProtocolMode = "vpnProtocolMode"
        static let remotePort = "remotePort"
        static let isUseSmallPackets = "isUseSmallPackets"


    }
}
