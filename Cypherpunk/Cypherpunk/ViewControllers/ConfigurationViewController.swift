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

class WifiNetworks: Object {
    dynamic var name: String = ""
    dynamic var isTrusted: Bool = false
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class ConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    @IBOutlet weak var tableView: UITableView!

    var notificationToken: NotificationToken!
    var wifiNetworksResult: Results<WifiNetworks>!
    
    private let helperTextColor = UIColor(red: 100 / 255.0, green: 160 / 255.0, blue: 160 / 255.0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var nib = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ToggleCell")
        
        nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MenuCell")
        
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case 0:
            rows = 2 // privacy settings
        case 1:
            rows = 1 // connection settings
        case 2:
            rows = 1 // auto wi-fi settings
        case 3:
            rows = 1 // trust cellular networks toggle
            
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
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell")! as! ToggleTableViewCell
            toggleCell.label.text = "Auto-Reconnect"
            toggleCell.toggle.isOn = mainStore.state.settingsState.blockAds
            toggleCell.toggle.addTarget(self, action: #selector(blockAdsChanged(_:)), for: .valueChanged)
            toggleCell.descriptionLabel.text = "Cypherpunk Privacy will attempt to automatically reconnect if the connection is interrupted."
            cell = toggleCell
        case 2:
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell")! as! ToggleTableViewCell
            toggleCell.label.text = "Auto Secure Networks"
            toggleCell.toggle.isOn = mainStore.state.settingsState.blockAds
            toggleCell.toggle.addTarget(self, action: #selector(blockAdsChanged(_:)), for: .valueChanged)
            toggleCell.descriptionLabel.text = "Cypherpunk Privacy can automatically secure connections to untrusted networks."
            cell = toggleCell
        case 3:
            cell = cellForTrustedNetworks(tableView, row: indexPath.row)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell")!
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 50.0
        if indexPath.section == 1 || indexPath.section == 2 {
            height = 100.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 30.0
        if section == 3 {
            height = 65.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        headerView.backgroundColor = UIColor.configTableCellBg
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 320, height: 30))
        label.textColor = UIColor.goldenYellow
        label.font = R.font.dosisSemiBold(size: 15.0)
        
        switch section {
        case 0:
            label.text = "Privacy Settings"
        case 1:
            label.text = "Connection Settings"
        case 2:
            label.text = "Network Auto Security"
        case 3:
            headerView = createHeaderWithDescriptionView(title: "Trusted Networks", description: "Select networks you trust that will be exempt from Auto Security.", numOfLines: 2)
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
    private func createHeaderWithDescriptionView(title: String, description: String, numOfLines: Int) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 65))
        headerView.backgroundColor = UIColor.configTableCellBg
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 320, height: 25))
        label.textColor = UIColor.goldenYellow
        label.font = R.font.dosisSemiBold(size: 15.0)
        label.text = title
        
        let descLabel = UILabel(frame: CGRect(x: 15, y: 30, width: tableView.bounds.width - 30, height: 40))
        descLabel.textColor = self.helperTextColor
        descLabel.numberOfLines = numOfLines
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.font = R.font.dosisRegular(size: 15)
        descLabel.text = description
        
        headerView.addSubview(label)
        headerView.addSubview(descLabel)
        
        return headerView
    }
    
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
            cell.toggle.isOn = wifiInfo.isTrusted
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
        
        let wifiInfo = wifiNetworksResult[sender.tag - 1] // offset by 1 because of the cellular cell
        try! realm.write {
            wifiInfo.isTrusted = sender.isOn
        }
        
        VPNConfigurationCoordinator.start {
        }
    }
    
    @IBAction func blockAdsChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockAds(block: sender.isOn))
    }
    
    @IBAction func blockMalwareChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockMalware(block: sender.isOn))
    }
    
    @IBAction func autoReconnectChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockMalware(block: sender.isOn))
    }
    
    @IBAction func autoSecureWifiNetworksChanged(_ sender: UISwitch) {
        mainStore.dispatch(SettingsAction.blockMalware(block: sender.isOn))
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    func newState(state: AccountState) {
        self.tableView.reloadData()
    }
}

