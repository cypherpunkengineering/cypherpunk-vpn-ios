//
//  VPNStateController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/17/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//
// TODO: This class isn't being used for it's original purpose anymore. Remaining functionality should be merged elsewhere.
import NetworkExtension

final class VPNStateController: UIResponder {
    
    private var connectAfterDisconnect = false
    
    //MARK: Shared Instance
    static let sharedInstance: VPNStateController = VPNStateController()
    
    private override init() {
        super.init()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        switch status {
        case .connected:
            print("VPN Connected")
            mainStore.state.regionState.serverPinger.cancelPinging()
        case .connecting:
            print("VPN Connecting")
        case .disconnecting:
            print("VPN Disconnecting")
        case .disconnected:
            print("VPN Disconnected")
            // check if we need to connect to another VPN
            if connectAfterDisconnect {
                VPNConfigurationCoordinator.connect()
                connectAfterDisconnect = false
            }
        case .reasserting:
            print("VPN Reasserting")
        case .invalid:
            print("VPN Invalid")
        }
    }
    
    // orchestrates reconnecting after initiating a disconnect
    func reconnect() {
        if VPNConfigurationCoordinator.isConnected || VPNConfigurationCoordinator.isConnecting {
            self.connectAfterDisconnect = true // wait for notification of disconnect
            VPNConfigurationCoordinator.disconnect()
        }
        else if VPNConfigurationCoordinator.isDisconnecting {
            // already disconnecting, just wait
            self.connectAfterDisconnect = true // wait for notification of disconnect
        }
        else if VPNConfigurationCoordinator.isDisconnected {
            // not connected just go ahead and connect
            VPNConfigurationCoordinator.connect()
        }
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
}
