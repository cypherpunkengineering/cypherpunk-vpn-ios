//
//  LocationSelectorViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/13/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift
import NetworkExtension

protocol LocationSelectionDelegate {
    func dismissSelector()
    func scrolledTo(location: Region)
    func locationSelected(location: Region)
}

enum LocationSection: Int {
    case cypherplay
//    case favorite
//    case recentlyConnected
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
        case .cypherplay:
            return realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: ConnectionHelper.baseRegionQueryPredicates())).sorted(byKeyPath: "latencySeconds")
//        case .favorite:
//            return realm.objects(Region.self).filter("isFavorite = true").sorted(byKeyPath: "lastConnectedDate", ascending: false)
//        case .recentlyConnected:
//            return realm.objects(Region.self).filter("isFavorite = false").filter("lastConnectedDate != %@", Date(timeIntervalSince1970: 1)).sorted(byKeyPath: "lastConnectedDate", ascending: false)
        default:
            let sortProperties = [
                SortDescriptor(keyPath: "country", ascending: true),
                SortDescriptor(keyPath: "name", ascending: true)
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
//        case .fastestLocation: return ""
//        case .favorite: return "favorite".uppercased()
//        case .recentlyConnected: return "Recently Connected".uppercased()
        case .cypherplay: return ""
        case .developer: return "Development".uppercased()
        case .NA: return "North America".uppercased()
        case .SA: return "Central & South America".uppercased()
        case .CR: return "Caribbean".uppercased()
        case .OP: return "Oceania & Pacific".uppercased()
        case .EU: return "Europe".uppercased()
        case .ME: return "Middle East".uppercased()
        case .AF: return "Africa".uppercased()
        case .AS: return "Asia & India Subcontinent".uppercased()
        }
    }
    
    static var regions: [LocationSection] {
        return [.developer, .NA, .SA, .CR, .OP, .EU, .ME, .AF, .AS].sorted{ return $0.rawValue < $1.rawValue }
    }
}

class LocationSelectorViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate: LocationSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 80.0 / 255.0, green: 1.0, blue: 1.0, alpha: 0.10)

        self.collectionView.register(UINib(nibName: "LocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LocationCell")
        self.collectionView.register(UINib(nibName: "CypherplayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CypherPlayCell")
        self.collectionView.register(UINib(nibName: "LocationHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.reloadData()
        
        let buttonText = String.fontAwesomeIcon(name: .chevronLeft) + " Back"
        let mutableString = NSMutableAttributedString(string: buttonText)
        mutableString.addAttribute(NSFontAttributeName, value: UIFont.fontAwesome(ofSize: 16), range: NSRange(location: 0, length: 1))
        mutableString.addAttribute(NSFontAttributeName, value: R.font.dosisSemiBold(size: 17)!, range: NSRange(location: 2, length: 4))
        mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenyBlue, range: NSRange(location: 0, length: 6))
        self.backButton.setAttributedTitle(mutableString, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.delegate?.dismissSelector()
    }
    
    func reloadLocations() {
        self.collectionView.reloadData()
    }
}

extension LocationSelectorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let section = LocationSection(rawValue: (indexPath as NSIndexPath).section)!
        let region = section.realmResults[indexPath.row]
        return region.authorized
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = LocationSection(rawValue: (indexPath as NSIndexPath).section)!
        
        if section == .cypherplay {
            ConnectionHelper.connectToFastest(cypherplay: true)
            self.delegate?.dismissSelector()
        }
        else {
            let location = section.realmResults[indexPath.row]
            ConnectionHelper.connectTo(region: location, cypherplay: false)
            self.delegate?.locationSelected(location: location)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.1) {
            cell?.backgroundColor = UIColor.greenyBlue
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.1) {
            cell?.backgroundColor = UIColor.clear
        }
    }
}

extension LocationSelectorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = LocationSection(rawValue: section)!
        
        switch section {
        case .cypherplay:
            return 1
        default:
            return section.realmResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        let section = LocationSection(rawValue: (indexPath as NSIndexPath).section)!
        
        switch section {
        case .cypherplay:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CypherPlayCell", for: indexPath)
        default:
            let locCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as! LocationCollectionViewCell
            let region = section.realmResults[indexPath.row]
            locCell.displayRegion(region: region)
            cell = locCell
        }
        return cell
    }
}

extension LocationSelectorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.bounds.width, height: 30)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let section = LocationSection(rawValue: (indexPath as NSIndexPath).section)!
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! LocationHeaderReusableView
            header.regionLabel.text = section.title.uppercased()
            return header
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! LocationHeaderReusableView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let locationSection = LocationSection(rawValue: section)
        if (locationSection?.realmResults.count)! > 0 {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
}
