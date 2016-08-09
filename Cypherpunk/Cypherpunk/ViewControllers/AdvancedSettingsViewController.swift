//
//  AdvancedSettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/09.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class AdvancedSettingsViewController: UITableViewController {
    
    private enum Section: Int {
        case Settings
        case VPNSettings
    }
    
    private enum VPNSettingsRow: Int {
        case VPNProtocol
        case RemotePort
        case UseSmallPackets
        case Encryption
        case PerAddSettings
    }

    @IBOutlet weak var autoReconnectSwitch: UISwitch!
    @IBOutlet weak var autoConnectOnBootSwitch: UISwitch!
    @IBOutlet weak var autoConnectVPNOnUntrustedSwitch: UISwitch!
    @IBOutlet weak var trustCellularNetworksSwitch: UISwitch!
    @IBOutlet weak var blockLocalNetworkSwitch: UISwitch!
    @IBOutlet weak var killSwitchSwitch: UISwitch!
    @IBOutlet weak var useSmallPacketsSwitch: UISwitch!
    
    @IBOutlet weak var vpnProtocolValueLabel: UILabel!
    @IBOutlet weak var remotePortValueLabel: UILabel!
    @IBOutlet weak var perAddSettingsValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadViews()
    }

    func reloadViews() {
        let state = mainStore.state.settingsState
        
        autoReconnectSwitch.setOn(state.isAutoReconnect, animated: true)
        autoConnectOnBootSwitch.setOn(state.isAutoConnectOnBoot, animated: true)
        autoConnectVPNOnUntrustedSwitch.setOn(state.isAutoConnectVPNOnUntrusted, animated: true)
        trustCellularNetworksSwitch.setOn(state.isTrustCellularNetworks, animated: true)
        blockLocalNetworkSwitch.setOn(state.isBlockLocalNetwork, animated: true)
        killSwitchSwitch.setOn(state.isKillSwitch, animated: true)
        useSmallPacketsSwitch.setOn(state.isUseSmallPackets, animated: true)
        
        vpnProtocolValueLabel.text = state.vpnProtocolMode.description
        remotePortValueLabel.text = state.remotePort.description
    }
}

extension AdvancedSettingsViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .Settings:
            break
        case .VPNSettings:
            let row = VPNSettingsRow(rawValue: indexPath.row)!
            switch row {
            case .VPNProtocol:
                let vc = VPNProtocolSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case .RemotePort:
                let vc = RemotePortSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case .UseSmallPackets:
                break
            case .Encryption:
                let vc = EncryptionSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case .PerAddSettings:
                let vc = AuthenticationSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
extension AdvancedSettingsViewController {
    
    @IBAction func changeAutoReconnectAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoReconnect(isOn: sender.on))
    }
    
    @IBAction func changeAutoConnectOnBootAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoConnectOnBoot(isOn: sender.on))
    }
    
    @IBAction func changeAutoConnectVPNOnUntrustedAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoConnectVPNOnUntrusted(isOn: sender.on))
    }
    
    @IBAction func changeTrustCellularNetworksAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isTrustCellularNetworks(isOn: sender.on))
    }
    
    @IBAction func changeBlockLocalNetworkAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isBlockLocalNetwork(isOn: sender.on))
    }
    
    @IBAction func changeKillSwitchAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isKillSwitch(isOn: sender.on))
    }
    
    @IBAction func changeUseSmallPacketsAction(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isUseSmallPackets(isOn: sender.on))
    }
    
    
    
}

