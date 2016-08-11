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
        
        self.tableView.configureView()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NEVPNIKEv2EncryptionAlgorithm.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = NEVPNIKEv2EncryptionAlgorithm.arrayDescription[indexPath.row]
        
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
        let value = NEVPNIKEv2EncryptionAlgorithm.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.encryption(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}

