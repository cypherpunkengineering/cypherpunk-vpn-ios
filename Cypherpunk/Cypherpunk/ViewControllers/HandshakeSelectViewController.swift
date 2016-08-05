//
//  HandshakeSelectViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

import NetworkExtension

@available(iOS 8.3, *)
extension NEVPNIKEv2CertificateType {
    static var arrayDescription: [NEVPNIKEv2CertificateType] {
        return [
            .RSA,
            .ECDSA256,
            .ECDSA384,
            .ECDSA521
        ]
    }
    
    static var count: Int {
        return arrayDescription.count
    }
}

@available(iOS 8.3, *)
class HandshakeSelectViewController: UITableViewController {

    var selectedValue: NEVPNIKEv2CertificateType = mainStore.state.settingsState.handshake
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Handshake"
        
        tableView.backgroundColor = UIColor(red: 26 / 255.0, green: 26 / 255.0, blue: 26 / 255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 69 / 255.0, green: 69 / 255.0, blue: 69 / 255.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NEVPNIKEv2CertificateType.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = NEVPNIKEv2CertificateType.arrayDescription[indexPath.row]
        
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
        let value = NEVPNIKEv2CertificateType.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.handshake(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
