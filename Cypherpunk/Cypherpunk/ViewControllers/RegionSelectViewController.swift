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

    static var array: [AreaIPAddress] {
        return [.Tokyo1, .Tokyo2, .Honolulu]
    }
    
    static var count: Int {
        return array.count
    }
}

class RegionSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: ThemedTableView!
    var areaNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        areaNames = ["Tokyo1","Tokyo2","Honolulu"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 17))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 300, height: 17))
        
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
        return ""
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        
        cell?.textLabel?.text = areaNames[indexPath.row]
        
        return cell!
    }
    
    private var areaName: String! = ""
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let area = AreaIPAddress(rawValue:indexPath.row)
        mainStore.dispatch(RegionAction.ChangeRegion(areaName: area!.areaName, countryName: area!.countryName, cityName: area!.cityName, serverIP: area!.IPAddress))
        VPNConfigurationCoordinator.start { 
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
