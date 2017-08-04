//
//  LeakProtectionTableViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/14/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class LeakProtectionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "OptionSelectorTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "OptionCell")
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
            label.text = "Leak Protection"
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // need this because on iPad the accessory view background is not correctly drawn
        cell.backgroundColor = UIColor.configTableCellBg
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionSelectorTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.label.text = "Always On"
            cell.accessoryType = mainStore.state.settingsState.alwaysOn ? .checkmark : .none
        case 1:
            cell.label.text = "Off"
            cell.accessoryType = mainStore.state.settingsState.alwaysOn ? .none : .checkmark
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
        
        let on = indexPath.row == 0 ? true : false
        
        mainStore.dispatch(SettingsAction.alwaysOn(isOn: on))
    }

}
