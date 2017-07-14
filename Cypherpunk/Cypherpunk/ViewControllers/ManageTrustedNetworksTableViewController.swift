//
//  ManageTrustedNetworksTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/13.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension.NEHotspotHelper
import SystemConfiguration.CaptiveNetwork
import RealmSwift

class WifiNetworks: Object {
    dynamic var name: String = ""
    dynamic var isTrusted: Bool = false
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class ManageTrustedNetworksTableViewController: UITableViewController {

    private enum Section: Int {
        case alwaysOn
        case autoSecure
        case otherNetworks
        case wifiNetworks
    }
    
    var notificationToken: NotificationToken!
    var wifiNetworksResult: Results<WifiNetworks>!
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ToggleCell")
        
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
        notificationToken = wifiNetworksResult.addNotificationBlock({ (change) in
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        })
    }

    
    deinit {
        notificationToken.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 1
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return cellForAutoSecureUntrusted(tableView, row: indexPath.row)
        }
        else {
            return cellForTrustedNetworks(tableView, row: indexPath.row)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        if section == 0 {
            headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 55)
            headerView.backgroundColor = UIColor.configTableCellBg
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: 320, height: 30))
            label.textColor = UIColor.goldenYellow
            label.font = R.font.dosisMedium(size: 15.0)
            label.text = "Auto Secure"
            
            let descLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.width - 30, height: 35))
            descLabel.textColor = UIColor.white
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byWordWrapping
            descLabel.font = R.font.dosisRegular(size: 12)
            descLabel.text = "Cypherpunk can automatically secure connections to untrusted networks."
            
            headerView.addSubview(label)
            headerView.addSubview(descLabel)
        }
        else if section == 1 {
            headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 65)
            headerView.backgroundColor = UIColor.configTableCellBg
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: 320, height: 30))
            label.textColor = UIColor.goldenYellow
            label.font = R.font.dosisMedium(size: 15.0)
            label.text = "Trusted Networks"
            
            let descLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.width - 30, height: 35))
            descLabel.textColor = UIColor.white
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byWordWrapping
            descLabel.font = R.font.dosisRegular(size: 12)
            descLabel.text = "Cypherpunk Privacy will automatically connect, except when on the following trusted networks."
            
            headerView.addSubview(label)
            headerView.addSubview(descLabel)
        }
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 55.0
        case 1:
            return 65.0
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
    }
    
    
    @IBAction func valueChangedOfAlwaysOnProtection(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.alwaysOn(isOn: sender.isOn))
    }
    
    @IBAction func valueChangedOfAutoSecureSwitchAction(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoSecureConnectionsWhenConnectedUntrustedNetwork(isOn: sender.isOn))
    }
    
    @IBAction func valueChangedOfOtherNetworksAutoSecureSwitchAction(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.isAutoSecureConnectionsWhenConnectedOtherNetwork(isOn: sender.isOn))
    }

    @IBAction func valueChangedOfIsTrustedNetworkSwitchAction(_ sender: UISwitch) {
        let realm = try! Realm()
        
        let wifiInfo = wifiNetworksResult[sender.tag]
        try! realm.write {
            wifiInfo.isTrusted = sender.isOn
        }
        
        VPNConfigurationCoordinator.start {
        }
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
            cell.toggle.isOn = wifiInfo.isTrusted
            cell.toggle.addTarget(self, action: #selector(handleTrustedNetworkValueChanged(_:)), for: .valueChanged)
            cell.toggle.tag = row
            
            cell.label.text = wifiInfo.name
        }
        
        return cell
    }
    
    private func cellForAutoSecureUntrusted(_ tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell") as! ToggleTableViewCell
        
        switch row {
        case 0:
            cell.label.text = "Auto Secure Untrusted Networks"
            cell.toggle.addTarget(self, action: #selector(valueChangedOfAutoSecureSwitchAction(_:)), for: .valueChanged)
            cell.toggle.isOn = mainStore.state.settingsState.isAutoSecureConnectionsWhenConnectedUntrustedNetwork
            
            if mainStore.state.settingsState.vpnProtocolMode == .IPSec {
                cell.isUserInteractionEnabled = false
                cell.toggle.isEnabled = false
            }
        default:
            break
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
            wifiInfo.isTrusted = sender.isOn
        }
        
        VPNConfigurationCoordinator.start {
            DispatchQueue.main.async {
                ReconnectDialogView.show()
            }
        }
    }
}
