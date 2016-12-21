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
        case autoSecure
        case otherNetworks
        case wifiNetworks
    }
    
    var notificationToken: NotificationToken!
    var wifiNetworksResult: Results<WifiNetworks>!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
            self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }

        switch section {
        case .autoSecure:
            return 1
        case .otherNetworks:
            return 1
        case .wifiNetworks:
            if wifiNetworksResult != nil {
                return wifiNetworksResult!.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .autoSecure:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.autoSecure, for: indexPath)
            cell?.isTrustedSwitch.isOn = mainStore.state.settingsState.isAutoSecureConnectionsWhenConnectedUntrustedNetwork
            return cell!
        case .otherNetworks:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.otherNetworks, for: indexPath)
            cell?.isTrustedSwitch.isOn = mainStore.state.settingsState.isAutoSecureConnectionsWhenConnectedOtherNetwork
            return cell!
        case .wifiNetworks:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.wifiNetworks, for: indexPath)
            
            let wifiInfo = wifiNetworksResult[indexPath.row]
            cell?.ssidLabel.text = wifiInfo.name
            cell?.isTrustedSwitch.isOn = wifiInfo.isTrusted
            cell?.isTrustedSwitch.addTarget(self, action: #selector(valueChangedOfIsTrustedNetworkSwitchAction(_:)), for: .valueChanged)
            cell?.isTrustedSwitch.tag = indexPath.row
            return cell!
            
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let section = Section(rawValue: section)!
        let titleLabel: UILabel
        titleLabel = UILabel(frame: CGRect(x: 15, y: 9, width: 300, height: 17))

        switch section {
        case .autoSecure:
            titleLabel.text = "Auto Secure"

            let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 31, width: 300, height: 36))
            descriptionLabel.text = "Cypherpunk can automatically secure connections to untrusted networks."
            descriptionLabel.font = R.font.dosisMedium(size: 14)
            descriptionLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 0.6)
            descriptionLabel.numberOfLines = 0
            view.addSubview(descriptionLabel)
        case .otherNetworks:
            titleLabel.text = "Other Networks"

            break
        case .wifiNetworks:
            titleLabel.text = "Wifi Networks"

            let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 31, width: 300, height: 36))
            descriptionLabel.text = "Add the networks you trust so Cypherpunk will now when connections should be secured."
            descriptionLabel.font = R.font.dosisMedium(size: 14)
            descriptionLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 0.6)
            descriptionLabel.numberOfLines = 0
            view.addSubview(descriptionLabel)
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.goldenYellow
        
        view.addSubview(titleLabel)
        
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = Section(rawValue: section)!
        
        switch section {
        case .autoSecure:
            return 80.0
        case .otherNetworks:
            return 40.0
        case .wifiNetworks:
            return 80.0
        }
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

    
}
