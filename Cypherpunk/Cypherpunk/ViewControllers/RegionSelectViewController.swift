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

enum RegionSection: Int {
    case fastestLocation
    case favorite
    case recentlyConnected
    case developer
    case NA
    case SA
    case CR
    case EU
    case ME
    case AF
    case AS
    case OP
    
    var realmResults: Results<Region> {
        let realm = try! Realm()
        switch self {
        case .fastestLocation:
            fatalError()
        case .favorite:
            return realm.objects(Region.self).filter("isFavorite = true").sorted(byProperty: "lastConnectedDate", ascending: false)
        case .recentlyConnected:
            return realm.objects(Region.self).filter("lastConnectedDate != %@", Date(timeIntervalSince1970: 1)).sorted(byProperty: "lastConnectedDate", ascending: false)
        default:
            let sortProperties = [
                SortDescriptor(property: "country", ascending: true),
                SortDescriptor(property: "name", ascending: true)
            ]
            return realm.objects(Region.self).filter("region == %@", self.regionCode).sorted(by:sortProperties)
        }
    }
    
    var regionCode: String! {
        switch self {
        case .developer: return "DEV"
        case .NA: return "NA"
        case .SA: return "SA"
        case .CR: return "CR"
        case .OP: return "OP"
        case .EU: return "EU"
        case .ME: return "ME"
        case .AF: return "AF"
        case .AS: return "AS"
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .fastestLocation: return ""
        case .favorite: return "favorite".uppercased()
        case .recentlyConnected: return "Recently Connected".uppercased()
        case .developer: return "Developer".uppercased()
        case .NA: return "North America".uppercased()
        case .SA: return "Central & South America".uppercased()
        case .CR: return "Caribbean".uppercased()
        case .OP: return "Oceania & Pacific".uppercased()
        case .EU: return "Europe".uppercased()
        case .ME: return "Middle East".uppercased()
        case .AF: return "Africa".uppercased()
        case .AS: return "Asia".uppercased()
        }
    }
    
    static var regions: [RegionSection] {
        return [.developer, .NA, .SA, .CR, .OP, .EU, .ME, .AF, .AS].sorted{ return $0.rawValue < $1.rawValue }
    }
}


class RegionSelectViewController: UITableViewController {
    
    fileprivate typealias Section = RegionSection
    
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
        notificationToken = realm.objects(Region.self).addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update:
                tableView.beginUpdates()
                let set = IndexSet(integersIn: NSRange(location: 0, length: tableView.numberOfSections).toRange() ?? 0..<0)
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
        return 12
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        if status == .connected {
            mainStore.dispatch(RegionAction.connect)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        
        switch section {
        case .fastestLocation:
            return 1
        case .recentlyConnected:
            let count = section.realmResults.count
            
            return count >= 3 ? 3 : count
        default:
            return section.realmResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.regionBasic, for: indexPath)
        cell?.starButton.isHidden = false
        cell?.flagImageView.image = nil
        cell?.titleLabel.isEnabled = true
        cell?.starButton.alpha = 1.0
        cell?.starButton.isUserInteractionEnabled = true
        cell?.isUserInteractionEnabled = true
        cell?.titleLabel.textColor = UIColor.white
        cell?.flagImageView.alpha = 1.0
        cell?.devLocationIconView.alpha = 1.0
        cell?.premiumLocationIconView.alpha = 1.0
        cell?.unavailableLabel.alpha = 1.0
        cell?.devLocationIconView.isHidden = true
        cell?.premiumLocationIconView.isHidden = true
        cell?.unavailableLabel.isHidden = true

        switch section {
        case .fastestLocation:
            cell?.titleLabel.text = "Fastest Location"
            cell?.starButton.isHidden = true
            cell?.flagImageView.image = R.image.colorHelmetSmall()
        default:
            let region = section.realmResults[indexPath.row]

            if mainStore.state.regionState.regionId == region.id {
                cell?.titleLabel.textColor = #colorLiteral(red: 0.9725490196, green: 0.8117647059, blue: 0.1098039216, alpha: 1)
            }
            cell?.titleLabel.text = region.name
            if region.isFavorite {
                cell?.starButton.setImage(R.image.iconStarOn(), for: .normal)
            } else {
                cell?.starButton.setImage(R.image.iconStar(), for: .normal)
            }
            cell?.flagImageView.image = UIImage(named: region.country.lowercased())
            
            if region.level == "premium" {
                cell?.premiumLocationIconView.isHidden = false
            } else if region.level == "developer" {
                cell?.devLocationIconView.isHidden = false
            }
            else if region.ipsecDefault == "" {
                cell?.unavailableLabel.isHidden = false
            }
            
            if region.enabled == false {
                cell?.titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
                cell?.titleLabel.isEnabled = false
                cell?.starButton.alpha = 0.5
                cell?.flagImageView.alpha = 0.5
                cell?.devLocationIconView.alpha = 0.5
                cell?.premiumLocationIconView.alpha = 0.5
                cell?.unavailableLabel.alpha = 0.5

                cell?.starButton.isUserInteractionEnabled = false
                cell?.isUserInteractionEnabled = false
            }
        }
        
        cell?.starButton.tag = indexPath.section * 100000 + indexPath.row
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var region: Region? = nil
        switch section {
        case .fastestLocation:
            mainStore.dispatch(RegionAction.setup)
        default:
            region = section.realmResults[indexPath.row]
        }
        
        tableView.visibleCells.forEach { (cell) in
            guard let cell = cell as? RegionTableViewCell else {
                return
            }
            cell.titleLabel.textColor = UIColor.white
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! RegionTableViewCell
        cell.titleLabel.textColor = #colorLiteral(red: 0.9725490196, green: 0.8117647059, blue: 0.1098039216, alpha: 1)
        if let region = region {
            mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.name, serverIP: region.ipsecDefault, countryCode: region.country, remoteIdentifier: region.ipsecHostname, level: region.level))
        }
        VPNConfigurationCoordinator.start {
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = Section(rawValue: section)!
        switch section {
        case .fastestLocation:
            return nil
        default:
            if section.realmResults.count == 0 {
                return UIView()
            }
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.backgroundColor = UIColor.clear

        let titleLabel = UILabel(frame: CGRect(x: 15, y: 14, width: self.view.frame.width, height: 17))
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.textColor = UIColor.white
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section.rawValue)

        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        spacerView.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        view.addSubview(spacerView)
        view.addSubview(titleLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)!.title
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = Section(rawValue: section)!
        switch section {
        case .fastestLocation:
            return 0.1
        default:
            if section.realmResults.count == 0 {
                return 0.1
            }
            return 40.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    @IBAction func didSelectFavoriteAction(_ sender: UIButton) {
        let row = sender.tag % 10000
        let section = Section(rawValue: sender.tag / 100000)!
        
        let target: Region
        switch section {
        case .fastestLocation:
            return
        default:
            target = section.realmResults[row]
        }
        let realm = try! Realm()
        try! realm.write {
            target.isFavorite = !target.isFavorite
            realm.add(target, update: true)
        }
    }
}
