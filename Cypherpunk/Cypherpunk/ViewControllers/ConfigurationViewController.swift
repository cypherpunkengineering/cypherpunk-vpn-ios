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
        var nib = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ToggleCell")
        
        nib = UINib(nibName: "DrilldownTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DrilldownCell")
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
            rows = 4
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
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 320, height: 30))
        label.textColor = UIColor.goldenYellow
        label.font = R.font.dosisSemiBold(size: 13.0)
        
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
        footerView.backgroundColor = UIColor.configTableBg
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            // automatic protection
            self.performSegue(withIdentifier: "PresentManageTrustedNetworks", sender: self)
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            // vpn mode
            self.performSegue(withIdentifier: "PresentVPNMode", sender: self)
        }
    }
    
    // MARK: Helper Methods
    private func cellForPrivacySettings(_ tableView: UITableView, row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell") as! ToggleTableViewCell
        
        switch row {
        case 0:
            let drilldownCell = tableView.dequeueReusableCell(withIdentifier: "DrilldownCell") as! DrilldownTableViewCell
            drilldownCell.label.text = "Automatic Protection"
            return drilldownCell
        case 1:
            let drilldownCell = tableView.dequeueReusableCell(withIdentifier: "DrilldownCell") as! DrilldownTableViewCell
            drilldownCell.label.text = "VPN Mode"
            return drilldownCell
        case 2:
            cell.label.text = "Block Ads"
        case 3:
            cell.label.text = "Block Malware"
        default:
            cell.label.text = ""
        }
        
        return cell
    }
}
