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
    
    case isAutoReconnect(isOn: Bool)
    case isAutoConnectOnBoot(isOn: Bool)
    case isAutoConnectVPNOnUntrusted(isOn: Bool)
    case isTrustCellularNetworks(isOn: Bool)
    case isBlockLocalNetwork(isOn: Bool)
    case isKillSwitch(isOn: Bool)
    
    case vpnProtocolMode(value: VPNProtocolMode)
    case remotePort(value: RemotePort)
    case isUseSmallPackets(isOn: Bool)

    case encryption(value: NEVPNIKEv2EncryptionAlgorithm)
    case authenitication(value: NEVPNIKEv2IntegrityAlgorithm)
    @available(iOS 8.3, *)
    case handshake(value: NEVPNIKEv2CertificateType)
}