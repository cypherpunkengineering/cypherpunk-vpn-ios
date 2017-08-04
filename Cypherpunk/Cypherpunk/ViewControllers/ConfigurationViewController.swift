//
//  ConfigurationViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/25/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import RealmSwift
import NetworkExtension.NEHotspotHelper
import SystemConfiguration.CaptiveNetwork
import ReSwift

class ConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    @IBOutlet weak var tableView: UITableView!

    var notificationToken: NotificationToken!
    var wifiNetworksResult: Results<WifiNetworks>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var nib = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ToggleCell")
        
        nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MenuCell")
        
        mainStore.subscribe(self) { $0.select { state in state.accountState } }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = mainStore.state.accountState.isDeveloperAccount ? 4 : 3
        default:
            break
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = cellForPrivacySettings(tableView, row: indexPath.row)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell")!
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        headerView.backgroundColor = UIColor.configTableCellBg
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 320, height: 30))
        label.textColor = UIColor.goldenYellow
        label.font = R.font.dosisSemiBold(size: 15.0)
        
        switch section {
        case 0:
            label.text = "Privacy Settings"
        default:
            label.text = ""
        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10))
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 2 {
            // automatic protection
            self.performSegue(withIdentifier: "PresentManageTrustedNetworks", sender: self)
        }
        else if indexPath.section == 0 && indexPath.row == 3 {
            // leak protection
            self.performSegue(withIdentifier: "PresentLeakProtection", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // need this because on iPad the accessory view background is not correctly drawn
        cell.backgroundColor = UIColor.configTableCellBg
    }
    
    // MARK: Helper Methods
    private func cellForPrivacySettings(_ tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell") as! ToggleTableViewCell
        
        switch row {
        case 0:
            cell.label.text = "Block Ads"
            cell.toggle.isOn = mainStore.state.settingsState.blockAds
            cell.toggle.addTarget(self, action: #selector(blockAdsChanged(_:)), for: .valueChanged)
        case 1:
            cell.label.text = "Block Malware"
            cell.toggle.isOn = mainStore.state.settingsState.blockMalware
            cell.toggle.addTarget(self, action: #selector(blockMalwareChanged(_:)), for: .valueChanged)
        case 2:
            let drilldownCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuTableViewCell
            drilldownCell.textLabel?.text = "Automatic Protection"
            return drilldownCell
        case 3:
            let drilldownCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuTableViewCell
            drilldownCell.textLabel?.text = "Leak Protection"
            return drilldownCell
        default:
            cell.label.text = ""
        }
        
        return cell
    }
    
    @IBAction func blockAdsChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockAds(block: sender.isOn))
    }
    
    @IBAction func blockMalwareChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockMalware(block: sender.isOn))
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    func newState(state: AccountState) {
        self.tableView.reloadData()
    }
}

