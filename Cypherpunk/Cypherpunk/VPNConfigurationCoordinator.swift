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
        manager.loadFromPreferencesWithCompletionHandler { (error) in
            completion()
        }
    }
    
    class func start(completion: () -> ()) {
        let manager = NEVPNManager.sharedManager()
        manager.loadFromPreferencesWithCompletionHandler { (error) in
            
            let newIPSec : NEVPNProtocolIPSec
            if mainStore.state.settingsState.vpnProtocolMode == .IKEv2 {
                newIPSec = NEVPNProtocolIKEv2()
                
                newIPSec.authenticationMethod = .None
                newIPSec.serverAddress = mainStore.state.regionState.serverIP
                
                newIPSec.username = "testuser"
                let password = "testpassword"
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReferenceForSavedPassword(password, forKey: "password")
                
                newIPSec.localIdentifier = String.randomStringForLocalIdentifier()
                newIPSec.remoteIdentifier = "d06f348c.wiz.network"
                
                newIPSec.useExtendedAuthentication = true
            } else {
                newIPSec = NEVPNProtocolIPSec()
                
                newIPSec.authenticationMethod = .SharedSecret
                newIPSec.serverAddress = mainStore.state.regionState.serverIP
                
                let pskString = "presharedsecretkey"
                newIPSec.sharedSecretReference = VPNPersistentDataGenerator.persistentReferenceForSavedPassword(pskString, forKey: "psk")
                
                newIPSec.username = "testuser"
                let password = "testpassword"
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReferenceForSavedPassword(password, forKey: "password")
                
                newIPSec.useExtendedAuthentication = true
                
                newIPSec.localIdentifier = String.randomStringForLocalIdentifier()
                newIPSec.remoteIdentifier = "vpn.cypherpunk.com"
            }



            newIPSec.disconnectOnSleep = false
            
            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }
            
            manager.localizedDescription = "Cyperpunk VPN"
            
            manager.onDemandEnabled = false
            manager.enabled = true
            
            manager.saveToPreferencesWithCompletionHandler({ (error) in
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


private extension String {
    static func randomStringForLocalIdentifier() -> String {
        
        let keychain = Keychain()
        let accessKey = "com.cypherpunk.data.localIdentifier.key"
        if let wrappedIdentifier = try? keychain.getString(accessKey), let unwrapped = wrappedIdentifier {
            return unwrapped
        } else {
            let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let upperBound = UInt32(alphabet.characters.count)
            
            let localIdentifier =  String((0..<10).map { _ -> Character in
                return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(upperBound)))]
                })
            
            try! keychain.set(localIdentifier, key: accessKey)
            return localIdentifier
        }
        
    }
}