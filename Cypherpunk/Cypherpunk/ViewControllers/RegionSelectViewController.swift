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

enum AreaIPAddress: Int {
    case Tokyo1
    case Tokyo2
    case Honolulu

    var IPAddress: String {
        switch self {
        case .Tokyo1: return "208.111.52.1"
        case .Tokyo2: return "208.111.52.2"
        case .Honolulu: return "199.68.252.203"
        }
    }
    
    var countryName: String {
        switch self {
        case .Tokyo1: return "Japan"
        case .Tokyo2: return "Japan"
        case .Honolulu: return "America"
        }
    }

    var areaName: String {
        switch self {
        case .Tokyo1: return "Tokyo1"
        case .Tokyo2: return "Tokyo2"
        case .Honolulu: return "Honolulu"
        }
    }

    var cityName: String {
        switch self {
        case .Tokyo1: return "Tokyo1"
        case .Tokyo2: return "Tokyo2"
        case .Honolulu: return "Honolulu"
        }
    }

    var isFavorited: Bool {
        switch self {
        case .Tokyo1: return true
        case .Tokyo2: return false
        case .Honolulu: return false
        }
    }
    
    var isRecommended: Bool {
        switch self {
        case .Tokyo1: return true
        case .Tokyo2: return true
        case .Honolulu: return false
        }
    }
    static var array: [AreaIPAddress] {
        return [.Tokyo1, .Tokyo2, .Honolulu]
    }
    
    static var count: Int {
        return array.count
    }
}

class RegionSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private enum Section: Int {
        case favorite
        case recommended
        case allLocation
    }
    
    @IBOutlet weak var tableView: ThemedTableView!
    var areaNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel: UILabel
        if section == 0 {
            titleLabel = UILabel(frame: CGRect(x: 20, y: 26, width: 300, height: 17))
        } else {
            titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        }
        
        titleLabel.font = R.font.dosisMedium(size: 14)
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let theme = mainStore.state.themeState.themeType
        switch theme {
        case .White:
            titleLabel.textColor = UIColor.whiteThemeTextColor()
        case .Black:
            titleLabel.textColor = UIColor.whiteThemeIndicatorColor()
        case .Indigo:
            titleLabel.textColor = UIColor.whiteColor()
        }
        
        view.addSubview(titleLabel)
        
        return view
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["FAVORITE","RECOMMENDED","ALL LOCATIONS"][section]
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areasInSection(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = Section(rawValue: indexPath.section)!
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        let areas = areasInSection(indexPath.section)
        
        cell?.titleLabel.text = areas[indexPath.row].cityName
        
        switch section {
        case .favorite:
            cell?.starButton.setImage(R.image.iconStarOn(), forState: .Normal)
        default:
            cell?.starButton.setImage(R.image.iconStar(), forState: .Normal)
        }
        
        return cell!
    }
    
    func areasInSection(section: Int) -> [AreaIPAddress] {
        let section = Section(rawValue: section)
        
        switch section! {
        case .favorite:
            return AreaIPAddress.array.filter({
                return $0.isFavorited
            })
        case .recommended:
            return AreaIPAddress.array.filter({
                return $0.isRecommended
            }).filter({
                return !$0.isFavorited
            })
        case .allLocation:
            return AreaIPAddress.array.filter({
                return !$0.isFavorited
            }).filter({
                return !$0.isRecommended
            })

        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let areas = areasInSection(indexPath.section)
        let area = areas[indexPath.row]
        mainStore.dispatch(RegionAction.ChangeRegion(areaName: area.areaName, countryName: area.countryName, cityName: area.cityName, serverIP: area.IPAddress))
        VPNConfigurationCoordinator.start { 
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
