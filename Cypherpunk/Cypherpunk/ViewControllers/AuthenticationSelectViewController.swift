//
//  AuthenticationSelectViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

extension NEVPNIKEv2IntegrityAlgorithm {
    static var arrayDescription: [NEVPNIKEv2IntegrityAlgorithm] {
        return [
            .SHA96,
            .SHA160,
            .SHA256,
            .SHA384,
            .SHA512
        ]
    }
    
    static var count: Int {
        return arrayDescription.count
    }
}

class AuthenticationSelectViewController: UITableViewController {
    
    var selectedValue: NEVPNIKEv2IntegrityAlgorithm = mainStore.state.settingsState.authenitication
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Authentication"
        
        self.tableView.reloadView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NEVPNIKEv2IntegrityAlgorithm.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = NEVPNIKEv2IntegrityAlgorithm.arrayDescription[indexPath.row]
        
        cell.prepareDisclosureIndicator()
        cell.reloadView()
        
        cell.textLabel?.text = value.description
        if value == selectedValue {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let value = NEVPNIKEv2IntegrityAlgorithm.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.authenitication(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}
