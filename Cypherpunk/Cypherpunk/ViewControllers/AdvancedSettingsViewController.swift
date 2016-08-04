//
//  AdvancedSettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class AdvancedSettingsViewController: UITableViewController {

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
