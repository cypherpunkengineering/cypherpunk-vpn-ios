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

    var region: Region? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let realm = try! Realm()
        region = realm.objects(Region).first
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return region?.areas.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        cell?.textLabel?.text = region?.areas[indexPath.row].name
        return cell!
    }
    
    private var areaName: String! = ""
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        areaName = region?.areas[indexPath.row].name
        
        self.performSegueWithIdentifier(R.segue.regionSelectViewController.toCountry, sender: nil)
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


class CountrySelectViewController: UITableViewController {
    
    var areaName: String? = nil
    var area: Area? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let realm = try! Realm()
        let result = realm.objects(Area).filter("name BEGINSWITH %@", areaName!)
        print(result)
        area = result.first
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
            destination.countryName = countryName
        }
    }
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return area?.countries.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        
        if let country = area?.countries[indexPath.row] {
            cell?.textLabel?.text = country.name
            if country.servers.count == 1 {
                cell?.accessoryType = .None
            } else {
                cell?.accessoryType = .DisclosureIndicator
            }
        }
        
        return cell!
    }
    
    private var countryName: String? = nil
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let country = area?.countries[indexPath.row] {
            
            if country.servers.count == 1 {
                if let server = country.servers.first {
                    mainStore.dispatch(RegionAction.ChangeRegion(cityName: server.city, serverIP: server.ip))
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                countryName = country.name
                self.performSegueWithIdentifier(R.segue.countrySelectViewController.toServer, sender: nil)
            }
        }
    }
    
}

class ServerSelectViewController: UITableViewController {
    
    var countryName: String? = nil
    var country: Country? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let realm = try! Realm()
        let result = realm.objects(Country).filter("name BEGINSWITH %@", countryName!)
        country = result.first
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return country?.servers.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.regionBasic, forIndexPath: indexPath)
        cell?.textLabel?.text = country?.servers[indexPath.row].city
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let server = country?.servers[indexPath.row] {
            mainStore.dispatch(RegionAction.ChangeRegion(cityName: server.city, serverIP: server.ip))
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}



