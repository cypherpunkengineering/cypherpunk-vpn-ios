//
//  VPNProtocolSelectViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/09.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

extension VPNProtocolMode {
    static var arrayDescription: [VPNProtocolMode] {
        return [
            .IPSec,
            .IKEv2
        ]
    }
    
    static var count: Int {
        return arrayDescription.count
    }

}

class VPNProtocolSelectViewController: UITableViewController {
    var selectedValue: VPNProtocolMode = mainStore.state.settingsState.vpnProtocolMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "VPN protocol"
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VPNProtocolMode.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .default, reuseIdentifier: "Cell")
        let value = VPNProtocolMode.arrayDescription[(indexPath as NSIndexPath).row]
        
        cell.prepareDisclosureIndicator()
        cell.configureView()
        
        cell.textLabel?.text = value.description
        if value == selectedValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = VPNProtocolMode.arrayDescription[(indexPath as NSIndexPath).row]
        mainStore.dispatch(SettingsAction.vpnProtocolMode(value: value))
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}
