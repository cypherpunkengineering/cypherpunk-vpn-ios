//
//  VPNModeTableViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/10/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class VPNModeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "VPNModeTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "VPNModeCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
            headerView.backgroundColor = UIColor.configTableCellBg
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: 320, height: 30))
            label.textColor = UIColor.goldenYellow
            label.font = R.font.dosisMedium(size: 15.0)
            label.text = "VPN Mode"
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VPNModeCell", for: indexPath) as! VPNModeTableViewCell
        
        let protocolMode = mainStore.state.settingsState.vpnProtocolMode
        
        switch indexPath.row {
        case 0:
            cell.label.text = "Always On + Killswitch"
            cell.accessoryType = protocolMode == VPNProtocolMode.IPSec ? .checkmark : .none
        case 1:
            cell.label.text = "Auto Reconnect"
            cell.accessoryType = protocolMode == VPNProtocolMode.IKEv2 ? .checkmark : .none
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rows = tableView.indexPathsForVisibleRows
        rows?.forEach({ (rowIndexPath) in
            if rowIndexPath != indexPath {
                let row = tableView.cellForRow(at: rowIndexPath)
                row?.accessoryType = .none
            }
        })
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        var mode = VPNProtocolMode.IKEv2
        
        if indexPath.row == 0 {
            mode = VPNProtocolMode.IPSec
        }
        
        mainStore.dispatch(SettingsAction.vpnProtocolMode(value: mode))
    }
}
