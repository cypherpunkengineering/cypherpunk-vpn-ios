//
//  MainButtonsCollectionViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 1/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import RealmSwift
import NetworkExtension

private let reuseIdentifier = "Cell"

class MainButtonsCollectionViewController: UICollectionViewController {
    var delegate: MainButtonsDelegate?
    
    private let gridHelper = ButtonGridHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let cyperPlayNib = UINib(nibName: "CypherPlayCollectionViewCell", bundle: nil)
        self.collectionView!.register(cyperPlayNib, forCellWithReuseIdentifier: "CypherPlayCell")
        
        let fastestNib = UINib(nibName: "MenuGridCollectionViewCell", bundle: nil)
        self.collectionView!.register(fastestNib, forCellWithReuseIdentifier: "MenuGridCell")

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegionUpdateNotification), name: NSNotification.Name(rawValue: regionUpdateNotificationKey), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRegionUpdateNotification() {
        self.collectionView?.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridHelper.numberOfButtonsForGrid()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return gridHelper.setupButtonAt(indexPath: indexPath, collectionView: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = gridHelper.buttonActionForCellAt(indexPath: indexPath)
        print(action.type)
        
        switch (action.type) {
        case .CypherPlay:
            connectToFastest(cypherplay: true)
        case .Fastest:
            connectToFastest(cypherplay: false)
        case .FastestUS:
            connectToFastestUS()
        case .FastestUK:
            connectToFastestUK()
        case .SavedServer:
            ConnectionHelper.connectTo(region: action.server!)
        case .ServerList:
            delegate?.showServerList()
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    private func connectToFastest(cypherplay: Bool) {
        mainStore.dispatch(SettingsAction.cypherplayOn(isOn: cypherplay))
        
        var region: Region? = nil
        
        let accountType = mainStore.state.accountState.accountType
        
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter("level = '\(accountType!)' AND latencySeconds > 0.0").sorted(byKeyPath: "latencySeconds").first
        print(region!)
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!)
        }
    }
    
    private func connectToFastestUS() {
        mainStore.dispatch(SettingsAction.cypherplayOn(isOn: false))
        
        var region: Region? = nil
        
        let accountType = mainStore.state.accountState.accountType
        
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter("level = '\(accountType!)' AND latencySeconds > 0.0 AND country = 'US'").sorted(byKeyPath: "latencySeconds").first
        print(region!)
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!)
        }
    }
    
    private func connectToFastestUK() {
        mainStore.dispatch(SettingsAction.cypherplayOn(isOn: false))
        
        var region: Region? = nil
        
        let accountType = mainStore.state.accountState.accountType
        
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter("level = '\(accountType!)' AND latencySeconds > 0.0 AND country= 'GB'").sorted(byKeyPath: "latencySeconds").first
        print(region!)
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!)
        }
    }
}

extension MainButtonsCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ButtonGridHelper.sharedInstance.sizeForButton(index: indexPath.item)
    }
}

protocol MainButtonsDelegate {
    func showServerList()
}
