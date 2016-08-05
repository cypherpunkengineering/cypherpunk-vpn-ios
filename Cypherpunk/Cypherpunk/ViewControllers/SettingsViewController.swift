//
//  SettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PageContent {

    var pageIndex: Int = 0
    
    private enum Section: Int {
        case NetworkSettings
        case AdvancedSettings
        case CryptoSettings
        
        var title: String {
            switch self {
            case .NetworkSettings:
                return "NetworkSettings"
            case .AdvancedSettings:
                return "AdvancedSettings"
            case .CryptoSettings:
                return "CryptoSettings"
            }
        }
    }
    
    private enum CryptoSettingsRow: Int {
        case Encryption
        case Authentication
        case Handshake
    }
    
    @IBOutlet weak var cypherpunkModeSwitch: UISwitch!
    @IBOutlet weak var protectOnDeviceStartupSwitch: UISwitch!
    @IBOutlet weak var protectOnUntrustedNetworksSwitch: UISwitch!
    
    @IBOutlet weak var encryptionValueLabel: UILabel!
    @IBOutlet weak var autheniticationValueLabel: UILabel!
    @IBOutlet weak var handshakeValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let state = mainStore.state.settingsState
        
        cypherpunkModeSwitch.setOn(state.cypherpunkMode, animated: true)
        protectOnDeviceStartupSwitch.setOn(state.protectOnDeviceStartup, animated: true)
        protectOnUntrustedNetworksSwitch.setOn(state.protectOnUntrustedNetworks, animated: true)
        
        encryptionValueLabel.text = state.encryption.description
        autheniticationValueLabel.text = state.authenitication.description
        if #available(iOS 8.3, *) {
            handshakeValueLabel.text = state.handshake.description
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionValue = Section(rawValue: section)!
        if sectionValue == .CryptoSettings {
            if #available(iOS 8.3, *) {
                return 3
            } else {
                return 2
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = Section(rawValue: indexPath.section)!
        
        if section == .CryptoSettings {
            
            let row = CryptoSettingsRow(rawValue: indexPath.row)!
            
            switch row {
            case .Encryption:
                let vc = EncryptionSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case .Authentication:
                let vc = AuthenticationSelectViewController(style: .Grouped)
                self.navigationController?.pushViewController(vc, animated: true)
            case .Handshake:
                if #available(iOS 8.3, *) {
                    let vc = HandshakeSelectViewController(style: .Grouped)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = Section(rawValue: section)!.title
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
    
    @IBAction func changeCypherpunkMode(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.cypherpunkMode(isOn: sender.on))
    }
    
    @IBAction func changeProtectOnDeviceStartup(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.protectOnDeviceStartup(isOn: sender.on))
    }
    
    @IBAction func changeProtectOnUntrustedNetworks(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.protectOnUntrustedNetworks(isOn: sender.on))
    }
}
