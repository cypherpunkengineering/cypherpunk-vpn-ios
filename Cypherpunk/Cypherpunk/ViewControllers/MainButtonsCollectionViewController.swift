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


/**
 This view controller leverages a UICollectionView to manage the server buttons on the iPhone sized screens.
 It has multiple selection enabled but does not actually allow multiple cells to be selected at once. The reason for this is so that a server button can be selected and the server list button will still be clickable.
 **/

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
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegionUpdateNotification), name: NSNotification.Name(rawValue: regionSelectedNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVpnStatusChanged),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        // allowing multiple selection so a button can be selected and server list can be selected. will enforce single selection in code.
        self.collectionView?.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRegionUpdateNotification() {
        self.collectionView?.reloadData()
    }
    
    func handleRegionSelectedNotification() {
        let selectedIndexPaths = self.collectionView!.indexPathsForSelectedItems
        for indexPath in selectedIndexPaths! {
            self.collectionView?.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func handleVpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
//        let status = connection.status
        // TODO what should be done here?
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
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let action = gridHelper.buttonActionForCellAt(indexPath: indexPath)
        
        var selectable = true
        // if there isn't a server defined so don't allow it to be selected
        if action.type == .SavedServer && action.server == nil {
            selectable = false
        }
        return selectable
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        // prevent selected cells from being tapped on again and be deselected
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = gridHelper.buttonActionForCellAt(indexPath: indexPath)
        print(action.type)
        
        if action.type == .ServerList {
            // deselect the server list button, let any other button that is selected stay selected
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        else {
            // allow only the newly selected cell to be selected
            deselectAllOtherCells(indexPathToKeep: indexPath)
        }
        
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
            if let server = action.server {
                ConnectionHelper.connectTo(region: server, cypherplay: false)
            }
        case .ServerList:
            delegate?.showServerList()
        }
    }

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
        var region: Region? = nil
        
        let predicates = buildBasePredicates()
        
        let realm = try! Realm()
        let regions = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds")

        region = regions.first
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: cypherplay)
        }
    }
    
    private func connectToFastestUS() {
        var region: Region? = nil
        
        var predicates = buildBasePredicates()
        predicates.append(NSPredicate(format: "country = 'US'"))
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds").first

        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: false)
        }
    }
    
    private func connectToFastestUK() {
        var region: Region? = nil
        
        var predicates = buildBasePredicates()
        predicates.append(NSPredicate(format: "country = 'GB'"))
        
        let realm = try! Realm()
        
        region = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "latencySeconds").first
        
        if (region != nil) {
            ConnectionHelper.connectTo(region: region!, cypherplay: false)
        }
    }
    
    private func buildBasePredicates() -> [NSPredicate] {
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "authorized == true"))
        predicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "level == 'developer'")))
        
        return predicates
    }
    
    private func deselectAllOtherCells(indexPathToKeep: IndexPath) {
        let selectedItemsIndexPaths = collectionView?.indexPathsForSelectedItems
        for selectedIndexPath in selectedItemsIndexPaths! {
            if selectedIndexPath != indexPathToKeep {
                collectionView?.deselectItem(at: selectedIndexPath, animated: true)
            }
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
