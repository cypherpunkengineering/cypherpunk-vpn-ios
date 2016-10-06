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

class RegionSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate enum Section: Int {
        case favorite
        case recommended
        case allLocation
    }
    
    @IBOutlet weak var tableView: ThemedTableView!
    
    var favoriteResults: Results<Region>!
    var recommendedResults: Results<Region>!
    var otherResults: Results<Region>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let realm = try! Realm()
        favoriteResults = realm.objects(Region.self).filter("isFavorite = true")
        recommendedResults = realm.objects(Region.self).filter("isFavorite = false AND isRecommended = true")
        otherResults = realm.objects(Region.self).filter("isFavorite = false AND isRecommended = false")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel: UILabel
        if section == 0 {
            titleLabel = UILabel(frame: CGRect(x: 20, y: 26, width: 300, height: 17))
        } else {
            titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        titleLabel.textColor = UIColor.white
        
        view.addSubview(titleLabel)
        
        return view
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Favorite","Recommended","All Locations"][section]
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!

        switch section {
        case .favorite:
            return favoriteResults.count
        case .recommended:
            return recommendedResults.count
        case .allLocation:
            return otherResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.regionBasic, for: indexPath)
        
        switch section {
        case .favorite:
            cell?.titleLabel.text = favoriteResults[indexPath.row].name
            cell?.starButton.setImage(R.image.iconStarOn(), for: .normal)
        case .recommended:
            cell?.titleLabel.text = recommendedResults[indexPath.row].name
            cell?.starButton.setImage(R.image.iconStar(), for: .normal)
        case .allLocation:
            cell?.titleLabel.text = otherResults[indexPath.row].name
            cell?.starButton.setImage(R.image.iconStar(), for: .normal)
        }
        
        cell?.starButton.tag = indexPath.section * 100000 + indexPath.row
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: (indexPath as NSIndexPath).section)!
        
        let region: Region
        switch section {
        case .favorite:
            region = favoriteResults[indexPath.row]
        case .recommended:
            region = recommendedResults[indexPath.row]
        case .allLocation:
            region = otherResults[indexPath.row]
        }

        mainStore.dispatch(RegionAction.changeRegion(name: region.name, serverIP: region.ipAddress))
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
        case .favorite:
            target = favoriteResults[row]
        case .recommended:
            target = recommendedResults[row]
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
