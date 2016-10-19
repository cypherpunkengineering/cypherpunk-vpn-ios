//
//  RegionSelectViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/07/08.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

import ReSwift
import RealmSwift
import NetworkExtension

class RegionSelectViewController: UITableViewController {
    
    fileprivate enum Section: Int {
        case fastestLocation
        case favorite
        case allLocation
    }
    
    var favoriteResults: Results<Region>!
    var otherResults: Results<Region>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )

        // Do any additional setup after loading the view.
        let realm = try! Realm()
        favoriteResults = realm.objects(Region.self).filter("isFavorite = true").sorted(byProperty: "lastConnectedDate", ascending: false)
        otherResults = realm.objects(Region.self).filter("isFavorite = false").sorted(byProperty: "lastConnectedDate", ascending: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        if status == .connected {
            mainStore.dispatch(RegionAction.connect)
            self.tableView.beginUpdates()
            let set = IndexSet(integersIn: NSRange(location: 0, length: 3).toRange() ?? 0..<0)
            self.tableView.reloadSections(set, with: .automatic)
            self.tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        
        switch section {
        case .fastestLocation:
            return 1
        case .favorite:
            return favoriteResults.count
        case .allLocation:
            return otherResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.regionBasic, for: indexPath)
        cell?.starButton.isHidden = false
        cell?.flagImageView.image = nil
        
        switch section {
        case .fastestLocation:
            cell?.titleLabel.text = "Fastest Location"
            cell?.starButton.isHidden = true
            cell?.flagImageView.image = R.image.iconAccount()
        case .favorite:
            cell?.titleLabel.text = favoriteResults[indexPath.row].regionName
            cell?.starButton.setImage(R.image.iconStarOn(), for: .normal)
            cell?.flagImageView.image = UIImage(named: favoriteResults[indexPath.row].countryCode.lowercased())
        case .allLocation:
            cell?.titleLabel.text = otherResults[indexPath.row].regionName
            cell?.starButton.setImage(R.image.iconStar(), for: .normal)
            cell?.flagImageView.image = UIImage(named: otherResults[indexPath.row].countryCode.lowercased())
        }
        
        cell?.starButton.tag = indexPath.section * 100000 + indexPath.row
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let region: Region
        switch section {
        case .fastestLocation:
            if favoriteResults.count > 0 {
                region = favoriteResults[0]
            } else {
                region = otherResults[0]
            }
        case .favorite:
            region = favoriteResults[indexPath.row]
        case .allLocation:
            region = otherResults[indexPath.row]
        }
        
        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.regionName, serverIP: region.ipsecDefault, countryCode: region.countryCode, remoteIdentifier: region.ipsecHostname))
        let manager = NEVPNManager.shared()
        let isConnected = manager.connection.status == .connected
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            VPNConfigurationCoordinator.start {
                self.dismiss(animated: true, completion: {
                    if isConnected {
                        try! VPNConfigurationCoordinator.connect()
                    }
                })
            }
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            VPNConfigurationCoordinator.start {
                if isConnected {
                    try! VPNConfigurationCoordinator.connect()
                }
            }
            
        }
    }
    
    @IBAction func didSelectFavoriteAction(_ sender: UIButton) {
        let row = sender.tag % 10000
        let section = Section(rawValue: sender.tag / 100000)!
        
        let target: Region
        switch section {
        case .fastestLocation:
            return
        case .favorite:
            target = favoriteResults[row]
        case .allLocation:
            target = otherResults[row]
        }
        let realm = try! Realm()
        try! realm.write {
            target.isFavorite = !target.isFavorite
            realm.add(target, update: true)
        }
        self.tableView.beginUpdates()
        let set = IndexSet(integersIn: NSRange(location: 0, length: 3).toRange() ?? 0..<0)
        self.tableView.reloadSections(set, with: .automatic)
        self.tableView.endUpdates()
    }
}
