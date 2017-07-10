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
        newIPSec.serverAddress = regionState.serverIP // IPSecDefault

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

    class func start(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in

            let settingsState = mainStore.state.settingsState
            let regionState = mainStore.state.regionState
            let accountState = mainStore.state.accountState

            let newIPSec : NEVPNProtocolIPSec
            if settingsState.vpnProtocolMode == .IKEv2
            {
                newIPSec = NEVPNProtocolIKEv2()

                newIPSec.authenticationMethod = .none
                newIPSec.serverAddress = regionState.serverIP // IPSecDefault

                newIPSec.useExtendedAuthentication = true
                newIPSec.username = accountState.vpnUsername
                let password = accountState.vpnPassword
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

                newIPSec.localIdentifier = generateLocalIdentifier()
                newIPSec.remoteIdentifier = regionState.remoteIdentifier // IPSecHostname
            }
            else
            {
                newIPSec = NEVPNProtocolIPSec()

                newIPSec.authenticationMethod = .none
                newIPSec.serverAddress = regionState.serverIP // IPSecDefault

                newIPSec.username = accountState.mailAddress

                newIPSec.useExtendedAuthentication = true
                newIPSec.username = accountState.vpnUsername
                let password = accountState.vpnPassword
                newIPSec.passwordReference = VPNPersistentDataGenerator.persistentReference(forSavedPassword: password, forKey: "password")

                newIPSec.localIdentifier = generateLocalIdentifier()
                newIPSec.remoteIdentifier = regionState.remoteIdentifier // IPSecHostname
            }


            newIPSec.disconnectOnSleep = false

            if #available(iOS 9.0, *) {
                manager.protocolConfiguration = newIPSec
            } else {
                manager.`protocol` = newIPSec
            }

            manager.localizedDescription = "Cypherpunk Privacy"

            if settingsState.isAutoSecureConnectionsWhenConnectedOtherNetwork && settingsState.isAutoSecureConnectionsWhenConnectedUntrustedNetwork {
                let wifiConnectRule = NEOnDemandRuleConnect()
                wifiConnectRule.interfaceTypeMatch = .wiFi

                let cellularConnectRule = NEOnDemandRuleConnect()
                cellularConnectRule.interfaceTypeMatch = .cellular

                manager.onDemandRules = [wifiConnectRule, cellularConnectRule]
                manager.isOnDemandEnabled = true
            } else if settingsState.isAutoSecureConnectionsWhenConnectedUntrustedNetwork {

                let realm = try! Realm()
                let whiteList = realm.objects(WifiNetworks.self).filter("isTrusted = true")

                var ssidList: [String] = []
                for netInfo in whiteList {
                    ssidList.append(netInfo.name)
                }

                let wifiConnectRule = NEOnDemandRuleConnect()
                wifiConnectRule.interfaceTypeMatch = .wiFi

                let cellularConnectRule = NEOnDemandRuleConnect()
                cellularConnectRule.interfaceTypeMatch = .cellular

                if ssidList.count != 0 {
                    let wifiDisconnectRule = NEOnDemandRuleDisconnect()
                    wifiDisconnectRule.interfaceTypeMatch = .wiFi
                    wifiDisconnectRule.ssidMatch = ssidList
                    
                    let wifiIggnoreRule = NEOnDemandRuleIgnore()
                    wifiIggnoreRule.interfaceTypeMatch = .wiFi
                    wifiIggnoreRule.ssidMatch = ssidList
                    
                    manager.onDemandRules = [wifiDisconnectRule,wifiIggnoreRule, wifiConnectRule, cellularConnectRule]
                } else {
                    manager.onDemandRules = [wifiConnectRule, cellularConnectRule]
                }

                manager.isOnDemandEnabled = true
            } else {
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
                completion()
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
            manager.saveToPreferences(completionHandler: { (error) in
                if let error = error {
                    print(error)
                } else {
                    connectBlock()
                }
            })
        } else {
            connectBlock()
        }
    }

    class func disconnect() {
        let manager = NEVPNManager.shared()
        manager.isOnDemandEnabled = false
        manager.saveToPreferences(completionHandler: { error in
            
        })
        if #available(iOS 9.0, *) {
            print("Stopping VPN tunnel to \(String(describing: manager.protocolConfiguration?.serverAddress))")
        } else {
            // Fallback on earlier versions
            print("Stopping VPN tunnel to \(String(describing: manager.protocol?.serverAddress))")
        }
        manager.connection.stopVPNTunnel()
    }

    class func removeFromPreferences() {
        let manager = NEVPNManager.shared()
        manager.removeFromPreferences(completionHandler: nil)
    }
    
    class var isProfileEnabled: Bool {
        set {
            let manager = NEVPNManager.shared()
            manager.isEnabled = newValue
            manager.isOnDemandEnabled = newValue
            manager.saveToPreferences { (error) in
                print(manager.isEnabled)
                
                // the profile is being enabled, connect to the VPN
                if newValue {
                    VPNConfigurationCoordinator.connect()
                }
                else {
                    if self.isConnected {
                        VPNConfigurationCoordinator.disconnect()
                    }
                }
                
            }
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
    
    private class func generateLocalIdentifier() -> String {
        let settingsState = mainStore.state.settingsState
        
        var bitmask = 10
        
        bitmask += settingsState.blockAds ? 1 : 0
        bitmask += settingsState.blockMalware ? 2 : 0
        bitmask += settingsState.cypherplayOn ? 4 : 0
        
        print("Local Identifier: cypherpunk-vpn-ios-\(bitmask)")
        return "cypherpunk-vpn-ios-\(bitmask)"
    }
}
