//
//  ConfigurationTableViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    @IBOutlet weak var vpnAlwaysOnSwitch: UISwitch!
    @IBOutlet weak var autoConnectOnBootSwitch: UISwitch!
    @IBOutlet weak var vpnProtocolValueLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        vpnProtocolValueLabel.text = mainStore.state.settingsState.vpnProtocolMode.description
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel: UILabel
        if section == 0 {
            titleLabel = UILabel(frame: CGRect(x: 15, y: 26, width: 300, height: 17))
        } else {
            titleLabel = UILabel(frame: CGRect(x: 15, y: 9, width: 300, height: 17))
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.goldenYellowColor()
        titleLabel.text = super.tableView(tableView, titleForHeaderInSection: section)
        
        view.addSubview(titleLabel)
        
        return view
    }
    
    @IBAction func changeValueOfAutoConnectOnBootAction(_ sender: UISwitch) {
        print("autoConnectOnBootSwitch is \(sender.isOn)")
    }
    @IBAction func changeValueOfAlwaysOnAction(_ sender: UISwitch) {
        print("vpnAlwaysOnSwitch is \(sender.isOn)")
    }

}
