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
import RealmSwift

open class VPNConfigurationCoordinator {

    class func load(_ completion: @escaping (Bool) -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in
            completion(error != nil)
        }
    }

    // if the VPN is active this will stop the tunnel
    class func start(connectIfDisconnected: Bool = false, _ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            let settingsState = mainStore.state.settingsState
            let regionState = mainStore.state.regionState
            let accountState = mainStore.state.accountState

            let newIPSec = buildIKEv2Configuration(accountState: accountState, regionState: regionState)

            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }

            let realm = try! Realm()
            let whiteList = realm.objects(WifiNetworks.self).filter("isTrusted = true")
            let blackList = realm.objects(WifiNetworks.self).filter("isTrusted = false")

            var ssidWhitelist: [String] = []
            for netInfo in whiteList {
                ssidWhitelist.append(netInfo.name)
            }
            var ssidBlacklist: [String] = []
            for netInfo in blackList {
                ssidBlacklist.append(netInfo.name)
            }

            if settingsState.alwaysOn {
                // if Leak Protection is "Always On"
                let alwaysConnectRule = NEOnDemandRuleConnect()
                alwaysConnectRule.interfaceTypeMatch = .any
                
                let cellularDisconnectRule = NEOnDemandRuleDisconnect()
                cellularDisconnectRule.interfaceTypeMatch = .cellular
                
                let wifiDisconnectRule = NEOnDemandRuleDisconnect()
                wifiDisconnectRule.interfaceTypeMatch = .wiFi
                wifiDisconnectRule.ssidMatch = ssidWhitelist
                
                if settingsState.isTrustCellularNetworks && ssidWhitelist.count != 0 {
                    manager.onDemandRules = [wifiDisconnectRule, cellularDisconnectRule, alwaysConnectRule]
                } else if settingsState.isTrustCellularNetworks {
                    manager.onDemandRules = [cellularDisconnectRule, alwaysConnectRule]
                } else if ssidWhitelist.count != 0 {
                    manager.onDemandRules = [wifiDisconnectRule, alwaysConnectRule]
                } else {
                    manager.onDemandRules = [alwaysConnectRule]
                }
            }
            else {
                // if Leak Protection is "Off"
                let cellularConnectRule = NEOnDemandRuleConnect()
                cellularConnectRule.interfaceTypeMatch = .cellular

                let wifiConnectRule = NEOnDemandRuleConnect()
                wifiConnectRule.interfaceTypeMatch = .wiFi
                wifiConnectRule.ssidMatch = ssidBlacklist

                if settingsState.isTrustCellularNetworks && ssidBlacklist.count != 0 {
                    manager.onDemandRules = [wifiConnectRule, cellularConnectRule]
                } else if settingsState.isTrustCellularNetworks {
                    manager.onDemandRules = [cellularConnectRule]
                } else if ssidWhitelist.count != 0 {
                    manager.onDemandRules = [wifiConnectRule]
                } else {
                    manager.onDemandRules = []
                }
            }
            
            manager.localizedDescription = "Cypherpunk Privacy"
            manager.isOnDemandEnabled = true
            manager.isEnabled = true

            let reconnect = self.isConnected || self.isConnecting || connectIfDisconnected

            manager.saveToPreferences(completionHandler: { (error) in
                completion()
                manager.loadFromPreferences(completionHandler: { (error) in
//                    print(manager.protocolConfiguration!)
                    if reconnect {
                        VPNConfigurationCoordinator.connect()
                    }
                })
            })
        }
    }

    class func connect() {

        let connectBlock = {
            let manager = NEVPNManager.shared()

            do {
                if #available(iOS 9.0, *) {
                    print("Starting VPN tunnel to \(String(describing: manager.protocolConfiguration?.serverAddress))")
                } else {
                    // Fallback on earlier versions
                    print("Starting VPN tunnel to \(String(describing: manager.protocol?.serverAddress))")
                }
                try manager.connection.startVPNTunnel()
            } catch NEVPNError.configurationInvalid {
                print("NEVPNError.configurationInvalid")
            } catch NEVPNError.configurationDisabled {
                print("NEVPNError.configurationDisabled")
            } catch {
                print("Unknown Error")
            }
        }

        let manager = NEVPNManager.shared()
        if manager.isOnDemandEnabled == false {
            manager.loadFromPreferences { (error) in
                manager.isOnDemandEnabled = true
                manager.saveToPreferences(completionHandler: { (error) in
                    manager.loadFromPreferences(completionHandler: { (error) in
//                        print(manager.protocolConfiguration!)
                    })
                    if let error = error {
                        print(error)
                    } else {
                        connectBlock()
                    }
                })
            }
        } else {
            connectBlock()
        }
    }

    class func disconnect() {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            if manager.isOnDemandEnabled {
                manager.isOnDemandEnabled = false
                
                // need to save is on demand enabled
                manager.saveToPreferences(completionHandler: { error in
                    manager.connection.stopVPNTunnel()
                    
                    manager.loadFromPreferences(completionHandler: { error in
                    })
                })
            }
            else {
                manager.connection.stopVPNTunnel()
            }
        }
        if #available(iOS 9.0, *) {
            print("Stopping VPN tunnel to \(String(describing: manager.protocolConfiguration?.serverAddress))")
        } else {
            // Fallback on earlier versions
            print("Stopping VPN tunnel to \(String(describing: manager.protocol?.serverAddress))")
        }
    }

    class func removeFromPreferences() {
        let manager = NEVPNManager.shared()
        manager.removeFromPreferences(completionHandler: nil)
    }

    class var isConnected: Bool {
        let manager = NEVPNManager.shared()
        if manager.connection.status == .connected {
            return true
        }
        return false
    }

    class var isConnecting: Bool {
        return NEVPNManager.shared().connection.status == .connecting
    }

    class var isDisconnecting: Bool {
        return NEVPNManager.shared().connection.status == .disconnecting
    }

    class var isDisconnected: Bool {
        return NEVPNManager.shared().connection.status == .disconnected
    }

    private class func generateLocalIdentifier() -> String {
        let settingsState = mainStore.state.settingsState
        let regionState = mainStore.state.regionState

        // generate random prefix to keep localIdentifier unique
        let alphabet : NSString = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(alphabet.length)
        var randomPrefix = ""
        for _ in 0 ..< 10 {
            let rand = arc4random_uniform(len)
            var nextChar = alphabet.character(at: Int(rand))
            randomPrefix += NSString(characters: &nextChar, length: 1) as String
        }

        // generate bitmask from user settings
        var bitmask = 10
        bitmask += settingsState.blockAds ? 1 : 0
        bitmask += settingsState.blockMalware ? 2 : 0
        bitmask += regionState.cypherplayOn ? 4 : 0

        // cat strings together
        let localIdentifier = randomPrefix + "-ios-\(bitmask)"

        // done
        print("Local Identifier: \(localIdentifier)")
        return localIdentifier
    }

    private class func buildIKEv2Configuration(accountState: AccountState, regionState: RegionState) -> NEVPNProtocolIKEv2 {
        let newIPSec = NEVPNProtocolIKEv2()

        newIPSec.authenticationMethod = .none
        newIPSec.serverAddress = regionState.remoteIdentifier // IPSecHostname

        newIPSec.useExtendedAuthentication = true
        newIPSec.username = accountState.vpnUsername
        let password = accountState.vpnPassword
        newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

        newIPSec.localIdentifier = generateLocalIdentifier()
        newIPSec.remoteIdentifier = regionState.remoteIdentifier // IPSecHostname

        newIPSec.deadPeerDetectionRate = .medium
        newIPSec.enablePFS = true
        newIPSec.serverCertificateCommonName = regionState.remoteIdentifier

        newIPSec.disconnectOnSleep = false

        return newIPSec
    }
}
