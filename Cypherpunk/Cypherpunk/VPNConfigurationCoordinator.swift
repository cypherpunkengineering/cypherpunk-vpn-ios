//
//  VPNConfigurationCoordinator.swift
//  VPNPrototype
//
//  Created by 木村圭佑 on 2016/06/07.
//  Copyright © 2016年 木村圭佑. All rights reserved.
//

import Foundation
import NetworkExtension

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
            
            // なければ作るし、あっても上書きしとけば問題ないのでerrorかどうかではわけない
            let newIPSec = NEVPNProtocolIKEv2()

            newIPSec.authenticationMethod = .None
            
            newIPSec.serverAddress = "tokyo.hide.me"
            newIPSec.username = "corosuke_k"
            
            
            let password = "A3w-kKF-yJs-EkQ"
            let passwordValue = password.dataUsingEncoding(NSUTF8StringEncoding)
            
            newIPSec.passwordReference = passwordValue

            newIPSec.useExtendedAuthentication = true

            newIPSec.localIdentifier = ""
            newIPSec.remoteIdentifier = "hide.me"
            
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
            try manager.connection.startVPNTunnelWithOptions(
                [
                    NEVPNConnectionStartOptionUsername : "corosuke_k",
                    NEVPNConnectionStartOptionPassword : "A3w-kKF-yJs-EkQ"
                ])
        } else {
            try manager.connection.startVPNTunnel()
        }
    }
    
    class func disconnect() {
        let manager = NEVPNManager.sharedManager()
        manager.connection.stopVPNTunnel()
    }
}