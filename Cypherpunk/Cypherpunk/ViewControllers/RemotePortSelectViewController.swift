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
        self.tableView.configureView()
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
        let cell = ThemedTableViewCell(style: .Default, reuseIdentifier: "Cell")
        let value = RemotePort.arrayDescription[indexPath.row]
        
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
        let value = RemotePort.arrayDescription[indexPath.row]
        mainStore.dispatch(SettingsAction.remotePort(value: value))
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}
