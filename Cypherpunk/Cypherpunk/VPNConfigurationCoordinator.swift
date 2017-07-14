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

    class func install(completion: ((Error?) -> Swift.Void)? = nil) {

        let regionState = mainStore.state.regionState
        let accountState = mainStore.state.accountState


        let manager = NEVPNManager.shared()
        let newIPSec : NEVPNProtocolIPSec

        newIPSec = NEVPNProtocolIKEv2()
        newIPSec.authenticationMethod = .none
        newIPSec.serverAddress = regionState.remoteIdentifier // IPSecHostname

        newIPSec.useExtendedAuthentication = true
        newIPSec.username = accountState.vpnUsername
        let password = accountState.vpnPassword
        newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

        newIPSec.localIdentifier = generateLocalIdentifier()
        newIPSec.remoteIdentifier = regionState.remoteIdentifier // IPSecHostname
        newIPSec.disconnectOnSleep = false

        if #available(iOS 9.0, *) {
            manager.protocolConfiguration = newIPSec
        } else {
            manager.`protocol` = newIPSec
        }

        manager.localizedDescription = "Cypherpunk Privacy"

        manager.isOnDemandEnabled = false
        manager.isEnabled = false

        manager.loadFromPreferences { (error) in
            if error == nil {
                manager.saveToPreferences(completionHandler: completion)
            }
            else {
                completion?(error)
            }
        }
    }
    
    // if the VPN is active this will stop the tunnel
    class func start(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            let settingsState = mainStore.state.settingsState
            let regionState = mainStore.state.regionState
            let accountState = mainStore.state.accountState

//            let newIPSec : NEVPNProtocolIPSec
//            if settingsState.vpnProtocolMode == .IKEv2 {
//                newIPSec = buildIKEv2Configuration(accountState: accountState, regionState: regionState)
//            }
//            else {
//                newIPSec = buildIPSecConfiguration(accountState: accountState, regionState: regionState)
//            }

            let newIPSec = buildIKEv2Configuration(accountState: accountState, regionState: regionState)

            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }

            manager.localizedDescription = "Cypherpunk Privacy"

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
/*
            if settingsState.vpnProtocolMode == .IKEv2 {
*/
                let cellularConnectRule = NEOnDemandRuleConnect()
                cellularConnectRule.interfaceTypeMatch = .cellular

                let wifiConnectRule = NEOnDemandRuleConnect()
                wifiConnectRule.interfaceTypeMatch = .wiFi
                wifiConnectRule.ssidMatch = ssidBlacklist

                if settingsState.isTrustCellularNetworks && ssidWhitelist.count != 0 {
                    manager.onDemandRules = [wifiConnectRule, cellularConnectRule]
                } else if settingsState.isTrustCellularNetworks {
                    manager.onDemandRules = [cellularConnectRule]
                } else if ssidWhitelist.count != 0 {
                    manager.onDemandRules = [wifiConnectRule]
                } else {
                    manager.onDemandRules = []
                }
/*
            } else if settingsState.vpnProtocolMode == .IPSec {
                let alwaysConnectRule = NEOnDemandRuleConnect()
                alwaysConnectRule.interfaceTypeMatch = .any

                let cellularDisconnectRule = NEOnDemandRuleDisconnect()
                cellularDisconnectRule.interfaceTypeMatch = .cellular

                let cellularIgnoreRule = NEOnDemandRuleIgnore()
                cellularIgnoreRule.interfaceTypeMatch = .cellular

                let wifiDisconnectRule = NEOnDemandRuleDisconnect()
                wifiDisconnectRule.interfaceTypeMatch = .wiFi
                wifiDisconnectRule.ssidMatch = ssidWhitelist

                let wifiIgnoreRule = NEOnDemandRuleIgnore()
                wifiIgnoreRule.interfaceTypeMatch = .wiFi
                wifiIgnoreRule.ssidMatch = ssidWhitelist

                if settingsState.isTrustCellularNetworks && ssidWhitelist.count != 0 {
                    manager.onDemandRules = [alwaysConnectRule, wifiDisconnectRule, wifiIgnoreRule, cellularDisconnectRule, cellularIgnoreRule]
                } else if settingsState.isTrustCellularNetworks {
                    manager.onDemandRules = [alwaysConnectRule, cellularDisconnectRule, cellularIgnoreRule]
                } else if ssidWhitelist.count != 0 {
                    manager.onDemandRules = [alwaysConnectRule, wifiDisconnectRule, wifiIgnoreRule]
                } else {
                    manager.onDemandRules = [alwaysConnectRule]
                }
            }
*/
            manager.isOnDemandEnabled = true
            manager.isEnabled = true

            let reconnect = self.isConnected || self.isConnecting
//            if self.isConnected || self.isConnecting {
//                // initiate a reconnect
////                VPNStateController.sharedInstance.reconnect()
//            }
            
            manager.saveToPreferences(completionHandler: { (error) in
                completion()
                manager.loadFromPreferences(completionHandler: { (error) in
                    print(manager.protocolConfiguration!)
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
        if manager.isOnDemandEnabled == false || manager.isEnabled == false {
            manager.loadFromPreferences { (error) in
                manager.isOnDemandEnabled = true
                manager.isEnabled = true
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
            
            manager.isOnDemandEnabled = false
            manager.isEnabled = false
            
            manager.saveToPreferences(completionHandler: { error in
                manager.connection.stopVPNTunnel()
                
                manager.loadFromPreferences(completionHandler: { error in
                })
            })
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

    class var isProfileEnabled: Bool {
        set {
            let manager = NEVPNManager.shared()
            
            manager.loadFromPreferences(completionHandler: { error in
                manager.saveToPreferences { (error) in
                    manager.isEnabled = newValue
                    manager.isOnDemandEnabled = newValue
                    
                    // the profile is being enabled, connect to the VPN
                    if newValue && !self.isConnected {
                        VPNConfigurationCoordinator.connect()
                    }
                    else {
                        if self.isConnected {
                            VPNConfigurationCoordinator.disconnect()
                        }
                    }
                    
                }
            })
        }
        get {
            let manager = NEVPNManager.shared()
            
            return manager.isEnabled
        }
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

        var bitmask = 10

        bitmask += settingsState.blockAds ? 1 : 0
        bitmask += settingsState.blockMalware ? 2 : 0
        bitmask += settingsState.cypherplayOn ? 4 : 0

        print("Local Identifier: cypherpunk-vpn-ios-\(bitmask)")
        return "cypherpunk-vpn-ios-\(bitmask)"
    }
    
    private class func buildIPSecConfiguration(accountState: AccountState, regionState: RegionState) -> NEVPNProtocolIPSec {
        let newIPSec : NEVPNProtocolIPSec = NEVPNProtocolIPSec()
        newIPSec.authenticationMethod = .certificate
        newIPSec.serverAddress = regionState.remoteIdentifier // IPSecHostname
        
        newIPSec.useExtendedAuthentication = true
        newIPSec.username = accountState.vpnUsername
        let password = accountState.vpnPassword
        newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")
        
        newIPSec.localIdentifier = generateLocalIdentifier()
        newIPSec.remoteIdentifier = regionState.remoteIdentifier // IPSecHostname
        
        if let cert = accountState.certificate {
            
            let p12 = Data(base64Encoded: cert)
            
            if #available(iOS 9.0, *) {
                newIPSec.identityReference = p12
            }
            
            newIPSec.identityData = p12
            newIPSec.identityDataPassword = "usr_cert"
        }
        
        newIPSec.disconnectOnSleep = false
        return newIPSec
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
        
        newIPSec.disconnectOnSleep = false
        return newIPSec
    }
}
