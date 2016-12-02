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

    class func install() {

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

        newIPSec.localIdentifier = "cypherpunk-vpn-ios"
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

        manager.saveToPreferences(completionHandler: { (error) in
            if error != nil {
            }
        })
    }

    class func start(_ completion: @escaping () -> ()) {
        let manager = NEVPNManager.shared()
        let status = manager.connection.status
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

                newIPSec.localIdentifier = "cypherpunk-vpn-ios"
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

                newIPSec.localIdentifier = "cypherpunk-vpn-ios"
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
                let connectBlock = {
                    let manager = NEVPNManager.shared()
                    
                    do {
                        try manager.connection.startVPNTunnel()
                    } catch NEVPNError.configurationInvalid {
                        print("NEVPNError.configurationInvalid")
                    } catch NEVPNError.configurationDisabled {
                        print("NEVPNError.configurationDisabled")
                    } catch {
                        print("Unknown Error")
                    }
                }
                

                if status == .connected, manager.isOnDemandEnabled == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: connectBlock)
                }
                completion()
            })
        }
    }

    class func connect() {

        let connectBlock = {
            let manager = NEVPNManager.shared()

            do {
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
        if manager.isEnabled == false {
            manager.isEnabled = true
            manager.saveToPreferences(completionHandler: { (error) in
                if error != nil {
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
        manager.saveToPreferences(completionHandler: nil)
        manager.connection.stopVPNTunnel()
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

}
