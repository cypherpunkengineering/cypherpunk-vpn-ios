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

open class VPNConfigurationCoordinator {

    class func load(_ completion: @escaping (Bool) -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in
            completion(error != nil)
        }
    }

    class func start(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            let newIPSec : NEVPNProtocolIPSec
            if mainStore.state.settingsState.vpnProtocolMode == .IKEv2
            {
                newIPSec = NEVPNProtocolIKEv2()

                newIPSec.authenticationMethod = .none
                newIPSec.serverAddress = mainStore.state.regionState.serverIP

                newIPSec.useExtendedAuthentication = true
                newIPSec.username = mainStore.state.accountState.mailAddress ?? "test@test.test"
                let password = "test123"
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

                newIPSec.localIdentifier = "cypherpunk-vpn-ios" // String.randomStringForLocalIdentifier() // "test.test.test"
                newIPSec.remoteIdentifier = "tokyo.vpn.cypherpunk.network"

                //let p12path = Bundle.main.path(forResource: "test", ofType: "p12")!
                //let p12data = try! Data(contentsOf: URL(fileURLWithPath: p12path))
                //newIPSec.identityData = p12data
                //newIPSec.identityDataPassword = ""
            }
            else
            {
                newIPSec = NEVPNProtocolIPSec()

                newIPSec.authenticationMethod = .none
                newIPSec.serverAddress = mainStore.state.regionState.serverIP

                newIPSec.username = mainStore.state.accountState.mailAddress ?? "test@test.test"
                //let pskString = "presharedsecretkey"
                //newIPSec.sharedSecretReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: pskString, forKey: "psk")

                newIPSec.useExtendedAuthentication = true
                newIPSec.username = mainStore.state.accountState.mailAddress ?? "test@test.test"
                let password = "test123"
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

                newIPSec.localIdentifier = "cypherpunk-vpn-ios" // String.randomStringForLocalIdentifier()
                newIPSec.remoteIdentifier = "tokyo.vpn.cypherpunk.network"
            }


            newIPSec.disconnectOnSleep = false

            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }

            manager.localizedDescription = "Cyperpunk VPN"

            if mainStore.state.settingsState.isAutoReconnect == true
            {
                //let evaluateRule = NEEvaluateConnectionRule(matchDomains: [ "*" ], andAction: .connectIfNeeded)
                //onDemandRule.connectionRules = [evaluateRule]
                
                let onDemandRule = NEOnDemandRuleConnect()
                manager.onDemandRules = [onDemandRule]
                manager.isOnDemandEnabled = true
            }
            else
            {
                manager.isOnDemandEnabled = false
            }
            

			if newIPSec.serverAddress != ""
			{
                manager.isEnabled = true
			}
			else
			{
                manager.isOnDemandEnabled = false
                manager.isEnabled = false
			}

            manager.saveToPreferences(completionHandler: { (error) in
                if error != nil {
                    print(error)
                }
                completion()
            })
        }
    }

    class func connect() throws {
        let manager = NEVPNManager.shared()
        if #available(iOS 9.0, *) {

            manager.isOnDemandEnabled = true
            manager.isEnabled = true
            manager.saveToPreferences(completionHandler: { (error) in
                if error != nil {
                    print(error)
                }
            })

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
        let manager = NEVPNManager.shared()
        manager.isOnDemandEnabled = false
        manager.isEnabled = false
        manager.saveToPreferences(completionHandler: { (error) in
            if error != nil {
                print(error)
            }
        })
        manager.connection.stopVPNTunnel()
    }
    
    class func removeFromPreferences() {
        let manager = NEVPNManager.shared()
        manager.removeFromPreferences(completionHandler: nil)
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
                return alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
                })

            try! keychain.set(localIdentifier, key: accessKey)
            return localIdentifier
        }

    }
}
