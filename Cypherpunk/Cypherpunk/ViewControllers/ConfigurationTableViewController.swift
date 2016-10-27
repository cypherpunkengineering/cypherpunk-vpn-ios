//
//  ConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    @IBOutlet weak var vpnAlwaysOnSwitch: UISwitch!
    @IBOutlet weak var autoConnectOnBootSwitch: UISwitch!
    @IBOutlet weak var vpnProtocolValueLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.tableView.isScrollEnabled = false
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        vpnProtocolValueLabel.text = mainStore.state.settingsState.vpnProtocolMode.description
        vpnAlwaysOnSwitch.isOn = mainStore.state.settingsState.isAutoReconnect
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func changeValueOfAutoConnectOnBootAction(_ sender: UISwitch) {
    }
    @IBAction func changeValueOfAlwaysOnAction(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoReconnect(isOn: sender.isOn))
    }

}
