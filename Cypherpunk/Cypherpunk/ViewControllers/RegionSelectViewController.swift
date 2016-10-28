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
        case recentlyConnected
        case allLocation
    }
    
    var favoriteResults: Results<Region>!
    var recentlyConnectedResults: Results<Region>!
    var nonFavoriteResults: Results<Region>!
    
    var notificationToken: NotificationToken? = nil
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
        nonFavoriteResults = realm.objects(Region.self).filter("isFavorite = false").sorted(byProperty: "lastConnectedDate", ascending: false)
        recentlyConnectedResults = nonFavoriteResults.filter("lastConnectedDate != %@", Date(timeIntervalSince1970: 1))
     
        notificationToken = realm.objects(Region.self).addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update:
                tableView.beginUpdates()
                let set = IndexSet(integersIn: NSRange(location: 0, length: 4).toRange() ?? 0..<0)
                tableView.reloadSections(set, with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        })
        
    }
    
    deinit {
        notificationToken?.stop()
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
        return 4
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        if status == .connected {
            mainStore.dispatch(RegionAction.connect)
            self.tableView.beginUpdates()
            let set = IndexSet(integersIn: NSRange(location: 0, length: 4).toRange() ?? 0..<0)
            self.tableView.reloadSections(set, with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func numberOfRowsInRecentlyConnectedSection() -> Int {
        if recentlyConnectedResults.count < 3 {
            return recentlyConnectedResults.count
        }
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        
        switch section {
        case .fastestLocation:
            return 1
        case .favorite:
            return favoriteResults.count
        case .recentlyConnected:
            return numberOfRowsInRecentlyConnectedSection()
        case .allLocation:
            return nonFavoriteResults.count - numberOfRowsInRecentlyConnectedSection()
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
            cell?.flagImageView.image = R.image.colorHelmetSmall()
        case .favorite:
            cell?.titleLabel.text = favoriteResults[indexPath.row].regionName
            cell?.starButton.setImage(R.image.iconStarOn(), for: .normal)
            cell?.flagImageView.image = UIImage(named: favoriteResults[indexPath.row].countryCode.lowercased())
        case .recentlyConnected:
            cell?.titleLabel.text = recentlyConnectedResults[indexPath.row].regionName
            cell?.starButton.setImage(R.image.iconStar(), for: .normal)
            cell?.flagImageView.image = UIImage(named: recentlyConnectedResults[indexPath.row].countryCode.lowercased())
        case .allLocation:
            cell?.titleLabel.text = nonFavoriteResults[indexPath.row + numberOfRowsInRecentlyConnectedSection()].regionName
            cell?.starButton.setImage(R.image.iconStar(), for: .normal)
            cell?.flagImageView.image = UIImage(named: nonFavoriteResults[indexPath.row + numberOfRowsInRecentlyConnectedSection()].countryCode.lowercased())
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
                region = nonFavoriteResults[0]
            }
        case .favorite:
            region = favoriteResults[indexPath.row]
        case .recentlyConnected:
            region = recentlyConnectedResults[indexPath.row]
        case .allLocation:
            region = nonFavoriteResults[indexPath.row + numberOfRowsInRecentlyConnectedSection()]
        }
        
        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.regionName, serverIP: region.ipsecDefault, countryCode: region.countryCode, remoteIdentifier: region.ipsecHostname))
        let manager = NEVPNManager.shared()
        let isConnected = manager.connection.status == .connected
        VPNConfigurationCoordinator.start {
            if isConnected {
                try! VPNConfigurationCoordinator.connect()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch Section(rawValue: section)! {
        case .fastestLocation:
            return nil
        case .favorite:
            if favoriteResults.count == 0 {
                return nil
            }
        case .recentlyConnected:
            if recentlyConnectedResults.count == 0 {
                return nil
            }
        case .allLocation:
            break
        }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        view.backgroundColor = UIColor.clear
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let titleLabel: UILabel
            
            titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 17))
            
            titleLabel.font = R.font.dosisMedium(size: 14)
            titleLabel.textColor = UIColor.goldenYellowColor()
            titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            
            view.addSubview(titleLabel)
            
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            switch Section(rawValue: section)! {
            case .fastestLocation:
                return nil
            case .favorite:
                if favoriteResults.count == 0 {
                    return nil
                }
                return "Favorite"
            case .recentlyConnected:
                if recentlyConnectedResults.count == 0 {
                    return nil
                }
                return "Recently Connected"
            case .allLocation:
                return "All Location"
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(rawValue: section)! {
        case .fastestLocation:
            return 0.1
        case .favorite:
            if favoriteResults.count == 0 {
                return 0.1
            }
        case .recentlyConnected:
            if recentlyConnectedResults.count == 0 {
                return 0.1
            }
        case .allLocation:
            break
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 17
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
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
        case .recentlyConnected:
            target = recentlyConnectedResults[row]
        case .allLocation:
            target = nonFavoriteResults[row + numberOfRowsInRecentlyConnectedSection()]
        }
        let realm = try! Realm()
        try! realm.write {
            target.isFavorite = !target.isFavorite
            realm.add(target, update: true)
        }
        self.tableView.beginUpdates()
        let set = IndexSet(integersIn: NSRange(location: 0, length: 4).toRange() ?? 0..<0)
        self.tableView.reloadSections(set, with: .automatic)
        self.tableView.endUpdates()
    }
}
