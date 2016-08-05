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
        
        tableView.backgroundColor = UIColor(red: 26 / 255.0, green: 26 / 255.0, blue: 26 / 255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 69 / 255.0, green: 69 / 255.0, blue: 69 / 255.0, alpha: 1.0)
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
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = NEVPNIKEv2IntegrityAlgorithm.arrayDescription[indexPath.row]
        
        cell.backgroundColor = UIColor(red: 42 / 255.0, green: 42 / 255.0, blue: 42 / 255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.tintColor = UIColor(red: 153 / 255.0, green: 153 / 255.0, blue: 153 / 255.0, alpha: 1.0)
        
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
