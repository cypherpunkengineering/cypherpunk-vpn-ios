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

class RegionSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: ThemedTableView!
    var areaNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let realm = try! Realm()
        let regions = realm.objects(Region)
        areaNames = regions.reduce([]) { (names, region) -> [String] in
            var ret = names
            if names.contains(region.area) == false {
                ret.append(region.area)
            }
            return ret
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
        if section == 0 {
            return "Recentry connected"
        }
        return "Region"
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mainStore.state.regionState.recentryConnected.count
        }
        return areaNames.count + 1 ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell?.textLabel?.text = mainStore.state.regionState.recentryConnected[indexPath.row].title
            cell?.accessoryType = .None
            
        default:
            if indexPath.row == 0 {
                cell?.textLabel?.text = "Auto select region"
                cell?.accessoryType = .None
            } else {
                cell?.textLabel?.text = areaNames[indexPath.row - 1]
            }
        }
        
        
        return cell!
    }
    
    private var areaName: String! = ""
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
