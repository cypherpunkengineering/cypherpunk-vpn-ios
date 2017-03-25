//
//  VPNStateController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/17/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import NetworkExtension

final class VPNStateController: UIResponder {
    private var activeServerOption: VPNServerOption?
    private var previousServerOption: VPNServerOption?
    
    private var disconnectingServerOption: VPNServerOption?
    private var connectAfterDisconnectOption: VPNServerOption?
    
    private var responders: Array<VPNStateResponder> = Array()
    
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
        
        print("VPN Status: \(status)")
        
        switch status {
        case .connected:
            responders.forEach({ (responder) in
                responder.connected(disconnectedOption: previousServerOption, connectedOption: activeServerOption)
            })
        case .connecting:
            print()
        case .disconnected:
            responders.forEach({ (responder) in
                responder.disconnected(disconnectedOption: activeServerOption)
            })
            
            previousServerOption = activeServerOption
            activeServerOption = nil
            
            // check if we need to connect to another VPN
            if let connectOption = connectAfterDisconnectOption {
                connectOption.connect()
                connectAfterDisconnectOption = nil
                activeServerOption = connectOption
            }
        default:
            print()
        }
    }
    
    func addResponder(vpnStateResponder: VPNStateResponder) {
        if !responders.contains(where: { $0 === vpnStateResponder }) {
            responders.append(vpnStateResponder)
        }
    }
    
    func removeResponder(vpnStateResponder: VPNStateResponder) {
        responders = responders.filter({ $0 !== vpnStateResponder })
    }
    
    func connect(newOption: VPNServerOption) {
        // if the VPN is connected, disconnect it
        if VPNConfigurationCoordinator.isConnected {
            connectAfterDisconnectOption = newOption
            VPNConfigurationCoordinator.disconnect()
        }
        else {
            previousServerOption = activeServerOption
            activeServerOption = newOption
            
            // else just start the connection
            newOption.connect()
        }
    }
    
    func disconnect() {
//        previousServerOption = activeServerOption
//        activeServerOption = nil
        
        disconnectingServerOption = activeServerOption
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
}
