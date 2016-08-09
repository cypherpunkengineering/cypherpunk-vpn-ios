//
//  SettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PageContent {
    
    private enum Section: Int {
        case HelpMeChoose
        case Settings
        case VPNSettings
        case About
    }
    
    private enum VPNSettingsRow: Int {
        case VPNProtocol
        case RemotePort
        case UseSmallPackets
        case Encryption
        case PerAddSettings
    }
    
    var pageIndex: Int = 0
    var isExpand = false {
        didSet {
            if isExpand {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {                                                     self.expandArrowImageView.transform = CGAffineTransformRotate(self.expandArrowImageView.transform, CGFloat(M_PI))
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {                                                     self.expandArrowImageView.transform = CGAffineTransformRotate(self.expandArrowImageView.transform, -1 * CGFloat(M_PI))
                    }, completion: nil)
            }
            
            tableView.beginUpdates()
            if isExpand == true {
                // open
                let removeRange = NSRange(location: 1, length: 2)
                let insertRange = NSRange(location: 1, length: 3)
                
                tableView.deleteSections(NSIndexSet(indexesInRange: removeRange), withRowAnimation: .None)
                tableView.insertSections(NSIndexSet(indexesInRange: insertRange), withRowAnimation: .None)
            } else {
                // close
                let removeRange = NSRange(location: 1, length: 3)
                let insertRange = NSRange(location: 1, length: 2)
                
                tableView.deleteSections(NSIndexSet(indexesInRange: removeRange), withRowAnimation: .None)
                tableView.insertSections(NSIndexSet(indexesInRange: insertRange), withRowAnimation: .None)
            }
            tableView.endUpdates()
        }
    }
    
    @IBOutlet weak var expandArrowImageView: UIImageView!
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
    @IBOutlet weak var versionValueLabel: UILabel!
    
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
        
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        versionValueLabel.text = "\(version!)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSection = super.numberOfSectionsInTableView(tableView)
        if isExpand == false {
            numberOfSection = numberOfSection - 1
        }
        return numberOfSection
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionValue = Section(rawValue: section)!
        
        if isExpand == false {
            if sectionValue == .Settings {
                return 1
            }
            else if sectionValue == .VPNSettings {
                return super.tableView(tableView, numberOfRowsInSection: section + 1)
            }
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)
        if section == .VPNSettings && isExpand == false {
            // About
            let aboutIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
            return super.tableView(tableView, cellForRowAtIndexPath: aboutIndexPath)
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var section = Section(rawValue: indexPath.section)
        if section == .VPNSettings && isExpand == false {
            section = Section(rawValue: indexPath.section + 1)
        }
        
        if section == .Settings {
            if indexPath.row == 0 {
                isExpand = !isExpand
            }
        }
        
        if section == .VPNSettings {
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        if section == 2 && isExpand == false {
            titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section + 1)
        } else {
            titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        }

        titleLabel.textColor = UIColor(red: 204.0 / 255.0 , green: 204.0 / 255.0 , blue: 204.0 / 255.0 , alpha: 1.0)
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension SettingsViewController {
    
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
