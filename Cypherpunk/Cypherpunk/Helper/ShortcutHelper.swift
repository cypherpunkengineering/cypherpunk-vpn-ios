//
//  ShortcutHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 10/2/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - Shortcut Types
enum ShortcutIdentifier: String {
    case Connect
    case Disconnect
    case Location
    case Cypherplay
    case Fastest
    
    init?(fullType: String) {
        guard let last = fullType.components(separatedBy: ".").last else { return nil }
        
        self.init(rawValue: last)
    }
    
    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
}

class ShortcutHelper {
    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"
    static let applicationShortcutUserInfoServerKey = "applicationShortcutUserInfoServerKey"
    
    static let showLocationListNotification = Notification.Name("com.cypherpunk.showLocationListNotificationKey")
    
    static func registerShortcutItems(_ application: UIApplication) {
        // Construct the items.
        var items = [UIApplicationShortcutItem]()
        
        let connectShortcut = createConnectDisconnectShortcut(application)
        
        items.append(connectShortcut)
        
        let chooseLocShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Location.type, localizedTitle: "Choose Location", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "location70x70"), userInfo: [
            ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Location.rawValue
            ]
        )
        
        items.append(chooseLocShortcut)
        
        let cypherplayShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Cypherplay.type, localizedTitle: "CypherPlay™", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "cypherplay70x70"), userInfo: [
            ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Cypherplay.rawValue
            ]
        )
        
        items.append(cypherplayShortcut)
        
        let fastestShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Fastest.type, localizedTitle: "Fastest Location", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "fastest-server70x70"), userInfo: [
            ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Fastest.rawValue
            ]
        )
        
        items.append(fastestShortcut)
        
        application.shortcutItems = items
    }
    
    static func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        switch (shortCutType) {
        case ShortcutIdentifier.Connect.type:
            ConnectionHelper.handleVPNStateChange(on: true)
            handled = true
            break
        case ShortcutIdentifier.Disconnect.type:
            ConnectionHelper.handleVPNStateChange(on: false)
            handled = true
        case ShortcutIdentifier.Location.type:
            NotificationCenter.default.post(name: showLocationListNotification, object: self)
            handled = true
            break
        case ShortcutIdentifier.Cypherplay.type:
            ConnectionHelper.connectToFastest(cypherplay: true)
            handled = true
            break
        case ShortcutIdentifier.Fastest.type:
            ConnectionHelper.connectToFastest(cypherplay: false)
            handled = true
            break
        default:
            break
        }
        
        return handled
    }

    private static func createConnectDisconnectShortcut(_ application: UIApplication) -> UIApplicationShortcutItem {
        var locationName: String = ""
        
        if mainStore.state.regionState.cypherplayOn {
            locationName = "CypherPlay™"
        }
        else if let regionId = mainStore.state.regionState.lastSelectedRegionId {
            let realm = try! Realm()
            if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                locationName = region.name
            }
        }
        
        if VPNConfigurationCoordinator.isDisconnected || VPNConfigurationCoordinator.isDisconnecting || !VPNConfigurationCoordinator.isEnabled {
            return UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Connect.type, localizedTitle: "Connect To", localizedSubtitle: locationName, icon: UIApplicationShortcutIcon(templateImageName: "3DmenuConnect"), userInfo: [
                ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Connect.rawValue
                ]
            )
        }
        else {
            return UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Disconnect.type, localizedTitle: "Disconnect From", localizedSubtitle: locationName, icon: UIApplicationShortcutIcon(templateImageName: "3DmenuConnect"), userInfo: [
                ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Disconnect.rawValue
                ]
            )
        }
    }
}
