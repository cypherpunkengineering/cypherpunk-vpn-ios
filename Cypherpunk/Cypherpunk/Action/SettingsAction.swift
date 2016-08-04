//
//  SettingsAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift
import NetworkExtension

enum SettingsAction: Action {
    case cypherpunkMode(isOn: Bool)
    case protectOnDeviceStartup(isOn: Bool)
    case protectOnUntrustedNetworks(isOn: Bool)
    
    case encryption(value: NEVPNIKEv2EncryptionAlgorithm)
    case authenitication(value: NEVPNIKEv2IntegrityAlgorithm)
    @available(iOS 8.3, *)
    case handshake(value: NEVPNIKEv2CertificateType)

}