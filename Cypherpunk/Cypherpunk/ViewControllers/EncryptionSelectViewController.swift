//
//  EncryptionSelectViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

import NetworkExtension

extension NEVPNIKEv2EncryptionAlgorithm {
    
    static var arrayDescription: [NEVPNIKEv2EncryptionAlgorithm] {
        var ret: [NEVPNIKEv2EncryptionAlgorithm] = []
        
        ret.append(.AlgorithmDES)
        ret.append(.Algorithm3DES)
        ret.append(.AlgorithmAES128)
        ret.append(.AlgorithmAES256)
        if #available(iOS 8.3, *) {
            ret.append(.AlgorithmAES128GCM)
            ret.append(.AlgorithmAES256GCM)
        }
        
        return ret
    }
    
    static var count: Int {
        return arrayDescription.count
    }
}

class EncryptionSelectViewController: UITableViewController {
    
    var selectedValue: NEVPNIKEv2EncryptionAlgorithm = mainStore.state.settingsState.encryption
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Encryption"
        
        tableView.backgroundColor = UIColor(red: 26 / 255.0, green: 26 / 255.0, blue: 26 / 255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 69 / 255.0, green: 69 / 255.0, blue: 69 / 255.0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NEVPNIKEv2EncryptionAlgorithm.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = NEVPNIKEv2EncryptionAlgorithm.arrayDescription[indexPath.row]
        
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
        let value = NEVPNIKEv2EncryptionAlgorithm.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.encryption(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

