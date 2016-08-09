//
//  RemotePortSelectViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/09.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

extension RemotePort {
    static var arrayDescription: [RemotePort] {
        return [
            .Auto
        ]
    }
    
    static var count: Int {
        return arrayDescription.count
    }
    
}

class RemotePortSelectViewController: UITableViewController {
    var selectedValue: RemotePort = mainStore.state.settingsState.remotePort
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Remote Port"
        
        tableView.backgroundColor = UIColor(red: 26 / 255.0, green: 26 / 255.0, blue: 26 / 255.0, alpha: 1.0)
        tableView.separatorColor = UIColor(red: 69 / 255.0, green: 69 / 255.0, blue: 69 / 255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RemotePort.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = RemotePort.arrayDescription[indexPath.row]
        
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
        let value = RemotePort.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.remotePort(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
