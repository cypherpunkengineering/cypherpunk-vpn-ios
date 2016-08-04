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

struct SettingsState: StateType {
    private let keychain = Keychain(service: "com.cyperpunk.ios.vpn.Settings")

    var cypherpunkMode: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.cypherpunkMode] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.cypherpunkMode] = String(newValue)
        }
    }
    
    var protectOnDeviceStartup: Bool {
        get{
            return NSString(string: keychain[SettingsStateKey.protectOnDeviceStartup] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.protectOnDeviceStartup] = String(newValue)
        }
    }
    var protectOnUntrustedNetworks: Bool {
        get {
            return NSString(string: keychain[SettingsStateKey.protectOnUntrustedNetworks] ?? "true").boolValue
        }
        set(newValue) {
            keychain[SettingsStateKey.protectOnUntrustedNetworks] = String(newValue)
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

        static let cypherpunkMode = "cypherpunkMode"
        static let protectOnDeviceStartup = "protectOnDeviceStartup"
        static let protectOnUntrustedNetworks = "protectOnUntrustedNetworks"
    }
}
