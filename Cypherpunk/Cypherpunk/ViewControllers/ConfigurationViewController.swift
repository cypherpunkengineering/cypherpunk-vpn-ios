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

class ConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var notificationToken: NotificationToken!
    var wifiNetworksResult: Results<WifiNetworks>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ToggleCell")
        
        // Load wifi networks
        if #available(iOS 9.0, *) {
            let interfaces = NEHotspotHelper.supportedNetworkInterfaces()
            for interface in interfaces {
                let realm = try! Realm()
                try! realm.write {
                    
                    if let interface = interface as? NEHotspotNetwork {
                        if realm.object(ofType: WifiNetworks.self, forPrimaryKey: interface.ssid) == nil {
                            let wifi = WifiNetworks()
                            wifi.name = interface.ssid
                            realm.add(wifi, update: false)
                        }
                        
                    }
                }
            }
        }
        
        let realm = try! Realm()
        wifiNetworksResult = realm.objects(WifiNetworks.self)
        // Listen to changes for wifi networks
        notificationToken = wifiNetworksResult.addNotificationBlock({ (change) in
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        })
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 2
        case 1:
            rows = 1
            
            if let results = wifiNetworksResult {
                rows += results.count
            }
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
        case 1:
            cell = cellForTrustedNetworks(tableView, row: indexPath.row)
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
        var height: CGFloat = 30.0
        switch section {
        case 1:
            height = 65.0
        default:
            break
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        headerView.backgroundColor = UIColor.configTableCellBg
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 320, height: 30))
        label.textColor = UIColor.goldenYellow
        label.font = R.font.dosisSemiBold(size: 13.0)
        
        switch section {
        case 0:
            label.text = "Privacy Settings"
        case 1:
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 65))
            headerView.backgroundColor = UIColor.configTableCellBg
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: 320, height: 30))
            label.textColor = UIColor.goldenYellow
            label.font = R.font.dosisSemiBold(size: 13.0)
            label.text = "Trusted Networks"
            
            let descLabel = UILabel(frame: CGRect(x: 20, y: 30, width: tableView.bounds.width - 30, height: 35))
            descLabel.textColor = UIColor.white
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byWordWrapping
            descLabel.font = R.font.dosisRegular(size: 12)
            descLabel.text = "Cypherpunk Privacy will automatically connect, except when on the following trusted networks"
            
            headerView.addSubview(label)
            headerView.addSubview(descLabel)
            
            return headerView
        default:
            label.text = ""
        }
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10))
        footerView.backgroundColor = UIColor.configTableBg
        return footerView
    }
    
    // MARK: Helper Methods
    private func cellForPrivacySettings(_ tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell") as! ToggleTableViewCell
        
        switch row {
        case 0:
            cell.label.text = "Block Ads"
        case 1:
            cell.label.text = "Block Malware"
        default:
            cell.label.text = ""
        }
        
        return cell
    }
    
    private func cellForTrustedNetworks(_ tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell") as! ToggleTableViewCell
        
        switch row {
        case 0:
            cell.label.text = "Trust Cellular Networks"
            cell.toggle.addTarget(self, action: #selector(handleTrustCellularValueChanged(_:)), for: .valueChanged)
            cell.toggle.isOn = mainStore.state.settingsState.isTrustCellularNetworks
        default:
            let wifiInfo = wifiNetworksResult[row - 1] // offset by 1 because of the celluar cell
            cell.toggle.isOn = !wifiInfo.isTrusted
            cell.toggle.addTarget(self, action: #selector(handleTrustedNetworkValueChanged(_:)), for: .valueChanged)
            cell.toggle.tag = row
            
            cell.label.text = wifiInfo.name
        }
        
        return cell
    }
    
    @IBAction func handleTrustCellularValueChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isTrustCellularNetworks(isOn: sender.isOn))
    }
    
    @IBAction private func handleTrustedNetworkValueChanged(_ sender: UISwitch) {
        let realm = try! Realm()
        
        let wifiInfo = wifiNetworksResult[sender.tag - 1] // offset by 1 because of the celluar cell
        try! realm.write {
            wifiInfo.isTrusted = !sender.isOn
        }
        
        VPNConfigurationCoordinator.start {
        }
    }
}