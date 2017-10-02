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
    case Cypherplay
    case Fastest
    case Location
    
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
    
    static func registerShortcutItems(_ application: UIApplication) {
        if application.shortcutItems != nil {
            // Construct the items.
            var items = [UIApplicationShortcutItem]()
            
            let connectShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Connect.type, localizedTitle: "Connect", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "3DmenuConnect"), userInfo: [
                ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Connect.rawValue
                ]
            )
            
            items.append(connectShortcut)
            
            let cypherplayShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Cypherplay.type, localizedTitle: "CypherPlay™", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "cypherplay70x70"), userInfo: [
                ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Cypherplay.rawValue
                ]
            )
            
            items.append(cypherplayShortcut)
            
            let fastestShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Cypherplay.type, localizedTitle: "Fastest Server", localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "fastest-server70x70"), userInfo: [
                ShortcutHelper.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Fastest.rawValue
                ]
            )
            
            items.append(fastestShortcut)
            
            //            let regions = ConnectionHelper.getUserLocations(count: 1)
            //            if regions.count > 0 {
            //                let region = regions.first
            //                let nameComponents = region?.name.components(separatedBy: ",")
            //                let locationShortcut = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Location.type, localizedTitle: (nameComponents?.first)!, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "location70x70"), userInfo: [
            //                    AppDelegate.applicationShortcutUserInfoIconKey: ShortcutIdentifier.Location.rawValue,
            //                    AppDelegate.applicationShortcutUserInfoServerKey: region?.id as Any
            //                    ]
            //                )
            //                items.append(locationShortcut)
            //            }
            
            application.shortcutItems = items
        }
    }
    
    static func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        switch (shortCutType) {
        case ShortcutIdentifier.Connect.type:
            //            VPNConfigurationCoordinator.connect()
            VPNStateController.sharedInstance.reconnect()
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
        case ShortcutIdentifier.Location.type:
            let regionId = shortcutItem.userInfo?[ShortcutHelper.applicationShortcutUserInfoServerKey]
            let realm = try! Realm()
            if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                ConnectionHelper.connectTo(region: region, cypherplay: false)
            }
            handled = true
            break
        default:
            break
        }
        
        return handled
    }
}
