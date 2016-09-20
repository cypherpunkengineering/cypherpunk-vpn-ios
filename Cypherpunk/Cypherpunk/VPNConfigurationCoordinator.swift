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

    class func load(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in
            completion()
        }
    }

    class func start(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            let newIPSec : NEVPNProtocolIPSec
            if mainStore.state.settingsState.vpnProtocolMode == .IKEv2
            {
                newIPSec = NEVPNProtocolIKEv2()

                newIPSec.authenticationMethod = .certificate
                newIPSec.serverAddress = mainStore.state.regionState.serverIP

                //newIPSec.username = mainStore.state.accountState.mailAddress ?? "testuser"
                //let password = "testpassword"
                //newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReferenceForSavedPassword(password, forKey: "password")

                newIPSec.localIdentifier = "test.test.test"
                newIPSec.remoteIdentifier = "vpn.cypherpunk.network"

                let p12path = Bundle.main.path(forResource: "test", ofType: "p12")!
                let p12data = try! Data(contentsOf: URL(fileURLWithPath: p12path))

                newIPSec.identityData = p12data
                newIPSec.identityDataPassword = ""
                newIPSec.useExtendedAuthentication = false
            }
            else
            {
                newIPSec = NEVPNProtocolIPSec()

                newIPSec.authenticationMethod = .sharedSecret
                newIPSec.serverAddress = mainStore.state.regionState.serverIP

                let pskString = "presharedsecretkey"
                newIPSec.sharedSecretReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: pskString, forKey: "psk")

                newIPSec.username = "testuser"
                let password = "testpassword"
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

                newIPSec.useExtendedAuthentication = true

                newIPSec.localIdentifier = ""
                newIPSec.remoteIdentifier = "vpn.cypherpunk.com"
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
                return alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
                })

            try! keychain.set(localIdentifier, key: accessKey)
            return localIdentifier
        }

    }
}
