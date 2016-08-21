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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VPNProtocolMode.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = VPNProtocolMode.arrayDescription[indexPath.row]
        
        cell.prepareDisclosureIndicator()
        cell.configureView()
        
        cell.textLabel?.text = value.description
        if value == selectedValue {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let value = VPNProtocolMode.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.vpnProtocolMode(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
