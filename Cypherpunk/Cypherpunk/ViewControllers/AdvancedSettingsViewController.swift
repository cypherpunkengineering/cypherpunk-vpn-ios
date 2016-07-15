//
//  AdvancedSettingsViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/14.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class AdvancedSettingsViewController: UITableViewController {

    @IBOutlet weak var connectWhenAppStartsSwitch: UISwitch!
    
    @IBOutlet weak var connectWhenWifiIsOnSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let state = mainStore.state.settingsState
        connectWhenAppStartsSwitch.on = state.connectWhenAppStarts
        connectWhenWifiIsOnSwitch.on = state.connectWhenWifiIsOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func changeConnectWhenAppStarts(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.ConnectWhenAppStarts(isOn: sender.on))
    }
    
    @IBAction func changeConnectWhenWifiIsOn(sender: UISwitch) {
        mainStore.dispatch(SettingsAction.ConnectWhenWifiIsOn(isOn: sender.on))
    }
    
}
