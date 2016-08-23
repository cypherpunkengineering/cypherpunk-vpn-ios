//
//  VPNConfigurationCoordinator.swift
//  VPNPrototype
//
//  Created by 木村圭佑 on 2016/06/07.
//  Copyright © 2016年 木村圭佑. All rights reserved.
//

import Foundation
import NetworkExtension
import KeychainAccess

public class VPNConfigurationCoordinator {
    
    class func load(completion: () -> ()) {
        let manager = NEVPNManager.sharedManager()
        // VPN設定をロードする。なければ作らなければいけない
        manager.loadFromPreferencesWithCompletionHandler { (error) in
            completion()
        }
    }
    
    class func start(completion: () -> ()) {
        let manager = NEVPNManager.sharedManager()
        // VPN設定をロードする。なければ作らなければいけない
        manager.loadFromPreferencesWithCompletionHandler { (error) in
            
            let newIPSec : NEVPNProtocolIPSec
            if mainStore.state.settingsState.vpnProtocolMode == .IKEv2 {
                newIPSec = NEVPNProtocolIKEv2()
                
                newIPSec.authenticationMethod = .None
                newIPSec.serverAddress = mainStore.state.regionState.serverIP
                
                newIPSec.username = "testuser"
                let password = "testpassword"
                newIPSec.passwordReference = VPNSharedSecretReferenceGenerator.persistentReferenceForSavedPassword(password, forKey: "password")
                
                newIPSec.useExtendedAuthentication = true
            } else {
                newIPSec = NEVPNProtocolIPSec()
                
                newIPSec.authenticationMethod = .SharedSecret
                newIPSec.serverAddress = mainStore.state.regionState.serverIP
                
                let pskString = "presharedsecretkey"
                newIPSec.sharedSecretReference = VPNSharedSecretReferenceGenerator.persistentReferenceForSavedPassword(pskString, forKey: "psk")

                newIPSec.username = "testuser"
                let password = "testpassword"
                newIPSec.passwordReference = VPNSharedSecretReferenceGenerator.persistentReferenceForSavedPassword(password, forKey: "password")
                
                newIPSec.useExtendedAuthentication = false
            }

            newIPSec.localIdentifier = ""
            newIPSec.remoteIdentifier = "d06f348c.wiz.network"


            newIPSec.disconnectOnSleep = false
            
            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }
            
            manager.localizedDescription = "Cyperpunk VPN"
            
            // ここだけ毎回saveしなければいけないpropertyのはずなので、別途その画面を作る際には毎回やる必要があるはず
            manager.onDemandEnabled = true
            manager.enabled = true
            
            // VPNProfileを保存する（最初の一回目はPermissionを得るために設定アプリに遷移して戻ってくる
            manager.saveToPreferencesWithCompletionHandler({ (error) in
                // VPNに接続
                if error != nil {
                    print(error)
                }
                completion()
            })
        }
    }
    
    class func connect() throws {
        let manager = NEVPNManager.sharedManager()
        if #available(iOS 9.0, *) {
            
            if mainStore.state.settingsState.vpnProtocolMode == .IKEv2 {
                try manager.connection.startVPNTunnel()
            } else {
                try manager.connection.startVPNTunnel()
                
            }
        } else {
            try manager.connection.startVPNTunnel()
        }
    }
    
    class func disconnect() {
        let manager = NEVPNManager.sharedManager()
        manager.connection.stopVPNTunnel()
    }
}