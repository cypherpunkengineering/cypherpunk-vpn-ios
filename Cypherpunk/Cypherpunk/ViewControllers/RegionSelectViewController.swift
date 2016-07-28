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

class RegionSelectViewController: UITableViewController {

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
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController
        
        if let destination = destination as? CountrySelectViewController {
            destination.areaName = areaName
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Recentry connected"
        }
        return "Region"
    }
        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mainStore.state.regionState.recentryConnected.count
        }
        return areaNames.count + 1 ?? 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        if indexPath.section == 1 {
            if row != 0 {
                areaName = areaNames[row - 1]
                self.performSegueWithIdentifier(R.segue.regionSelectViewController.toCountry, sender: nil)
                return
            } else {
                mainStore.dispatch(RegionAction.ActiveAutoSelect)
            }
        } else {
            let history = mainStore.state.regionState.recentryConnected[row]
            mainStore.dispatch(RegionAction.ChangeRegion(areaName: history.areaName, countryName: history.countryName, cityName: history.cityName, serverIP: history.serverIP))
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


class CountrySelectViewController: UITableViewController {
    
    var areaName: String! = nil
    var countryNames: [String] = []

    var areaResults: Results<Region>! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let realm = try! Realm()
        areaResults = realm.objects(Region).filter("area == %@", areaName)
        
        countryNames = areaResults.reduce([]) { (names, region) -> [String] in
            var ret = names
            if names.contains(region.countryCode) == false {
                ret.append(region.countryCode)
            }
            return ret
        }

        self.title = areaName
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController
        
        if let destination = destination as? ServerSelectViewController {
            destination.areaName = areaName
            destination.countryName = countryName
        }
    }
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryNames.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        
        let countryName = countryNames[indexPath.row]
        
        cell?.textLabel?.text = countryName
        if areaResults.filter("countryCode == %@", countryName).count == 1 {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .DisclosureIndicator
            
        }
        
        return cell!
    }
    
    private var countryName: String? = nil
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let countryName = countryNames[indexPath.row]
        
        let regionResults = areaResults.filter("countryCode == %@", countryName)
        if regionResults.count == 1 {
            if let region = regionResults.first {
                mainStore.dispatch(RegionAction.ChangeRegion(areaName: areaName, countryName: countryName, cityName: region.city, serverIP: region.ipAddress))
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            self.countryName = countryName
            self.performSegueWithIdentifier(R.segue.countrySelectViewController.toServer, sender: nil)
        }

    }
 
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
}

class ServerSelectViewController: UITableViewController {
    
    var areaName: String! = nil
    var countryName: String! = nil
    
    var cityNames: [String] = []
    var areaResults: Results<Region>! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let realm = try! Realm()
        areaResults = realm.objects(Region).filter("area == %@ AND countryCode == %@", areaName, countryName)
        
        cityNames = areaResults.reduce([]) { (names, region) -> [String] in
            var ret = names
            if names.contains(region.city) == false {
                ret.append(region.city)
            }
            return ret
        }

        self.title = countryName
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNames.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        cell?.textLabel?.text = cityNames[indexPath.row]
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let cityName = cityNames[indexPath.row]
        let regionResults = areaResults.filter("city == %@", cityName)

        if let region = regionResults.first {
            mainStore.dispatch(RegionAction.ChangeRegion(areaName: areaName, countryName: countryName, cityName: region.city, serverIP: region.ipAddress))
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}



