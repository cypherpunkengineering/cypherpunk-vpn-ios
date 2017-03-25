//
//  ButtonGridHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 1/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import RealmSwift

enum ButtonCellTypes: String {
    case CypherPlay
    case Fastest
    case FastestUS
    case FastestUK
    case ServerList
    case SavedServer
}

struct ButtonAction {
    var type: ButtonCellTypes
//    var server: Region?
    var favorite: Bool
    var recent: Bool
    var vpnServerOption: VPNServerOption
}

final class ButtonGridHelper {
    private var buttonActions : [ButtonAction]
    
    // Can't init singleton
    private init() {
        buttonActions = [ButtonAction]()
    }
    
    //MARK: Shared Instance
    static let sharedInstance: ButtonGridHelper = ButtonGridHelper()
    
    private func createButtonActions(buttonCount: Int) {
        buttonActions.removeAll() // clear out any actions
        
        let cypherplayServerOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .CypherPlay)
        cypherplayServerOption.cypherplay = true
        
        let fastestServerOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .Fastest)
        let noopServerOption = VPNServerOption(findServer: {(nil) -> Region? in return nil }, type: .Server)
        
        let fastestUSOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .FastestUS, country: "US")
        let fastestUKOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .FastestUK, country: "UK")
        
        // all layouts have a cyperplay, fastest, and server list
        let cyperplayAction = ButtonAction(type: .CypherPlay, favorite: false, recent: false, vpnServerOption: cypherplayServerOption)
        buttonActions.append(cyperplayAction) // this is always first
        
        let fastestAction = ButtonAction(type: .Fastest, favorite: false, recent: false, vpnServerOption: fastestServerOption)
        
        let serverList = ButtonAction(type: .ServerList, favorite: false, recent: false, vpnServerOption: noopServerOption)
        
        if (buttonCount == 3) {
            buttonActions.append(fastestAction)
            buttonActions.append(serverList)
        }
        else if (buttonCount == 5) {
            let locationButtonActions = locationButtonActionsByPriority(count: 2)
            
            buttonActions.append(fastestAction)
            
            buttonActions.append(locationButtonActions[1]) // location 2
            buttonActions.append(locationButtonActions.first!) // location 1
        }
        else if (buttonCount == 7) {
            let locationButtonActions = locationButtonActionsByPriority(count: 2)
            
            buttonActions.append(fastestAction)
            
            // First user based location
            if let locationAction = locationButtonActions.first {
                buttonActions.append(locationAction) // location 1
            }
            else {
                // append empty button action because no locations were available
                buttonActions.append(ButtonAction(type: .SavedServer, favorite: false, recent: false, vpnServerOption: noopServerOption))
            }
            
            let fastestUS = ButtonAction(type: .FastestUS, favorite: false, recent: false, vpnServerOption: fastestUSOption)
            buttonActions.append(fastestUS)
            
            // Second user based location
            if locationButtonActions.count > 1 {
                buttonActions.append(locationButtonActions[1]) // location 2
            }
            else {
                // append empty button action because no locations were available
                buttonActions.append(ButtonAction(type: .SavedServer, favorite: false, recent: false, vpnServerOption: noopServerOption))
            }
            
            let fastestUK = ButtonAction(type: .FastestUK, favorite: false, recent: false, vpnServerOption: fastestUKOption)
            buttonActions.append(fastestUK)
        }
        
        // server list action should always be last
        buttonActions.append(serverList)
    }
    
    func numberOfButtonsForGrid() -> Int {
        let realm = try! Realm()
        if realm.isEmpty || realm.objects(Region.self).isEmpty {
            return 0 // no servers yet
        }
        
        var buttonCount = 0
        
        // TODO: check idiom for iPad
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            buttonCount = 3
        }
        else if (UIScreen.main.bounds.height < 667) {
            // iPhone 5/5s size
            buttonCount = 5
        }
        else {
            // iPhone 6 and above
            buttonCount = 7
        }
        
        createButtonActions(buttonCount: buttonCount)
        
        return buttonCount
    }
    
    func heightForButtonAt(index: Int) -> Int {
        // TODO: check idiom for iPad
        if (index == 0 && UIScreen.main.bounds.height > 480) {
            // iPhone 5 and above
            return 200 - 1
        }
        else {
            return 100 - 1
        }
    }
    
    func heightForButtonGrid() -> Int {
        // TODO: check idiom for iPad
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            return 100
        }
        else {
            return 200
        }
    }

    func widthForButtonAt(index: Int) -> Int {
        // TODO: check idiom for iPad

        let screenWidth = UIScreen.main.bounds.width

        if (UIScreen.main.bounds.height > 568) {
            // iPhone 6 and above
            return Int(round(screenWidth /  4)) - 2
        }
        else {
            return Int(round(screenWidth /  3)) - 2
        }
    }

    func sizeForButton(index: Int) -> CGSize {
        return CGSize(width: widthForButtonAt(index: index), height: heightForButtonAt(index: index))
    }

    func setupButtonAt(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        // TODO: check idiom for iPad
        let action = buttonActionForCellAt(indexPath: indexPath)
        
        var cell : UICollectionViewCell? = nil
        switch action.type {
        case .CypherPlay:
            if UIScreen.main.bounds.height < 568 {
                // use a normal sized cell
                let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
                menuGridCell.iconView.image = R.image.topButtonKey()
                menuGridCell.textLabel.text = "CypherPlay"
                cell = menuGridCell
            }
            else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CypherPlayCell", for: indexPath)
            }
        case .Fastest:
            cell = fastestCell(indexPath: indexPath, collectionView: collectionView)
        case .FastestUS:
            cell = fastestUSCell(indexPath: indexPath, collectionView: collectionView)
        case .FastestUK:
            cell = fastestUKCell(indexPath: indexPath, collectionView: collectionView)
        case .SavedServer:
            cell = locationCell(indexPath: indexPath, collectionView: collectionView, action: action)
        case .ServerList:
            cell = serverListCell(indexPath: indexPath, collectionView: collectionView)
        }
        return cell!
    }

    private func fastestCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        menuGridCell.iconView.image = R.image.topButtonRocket()
        menuGridCell.textLabel.text = "Fastest"
        return menuGridCell
    }
    
    private func fastestUSCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        menuGridCell.iconView.image = R.image.us()
        menuGridCell.decoratorView.image = R.image.topButtonRocketSmall()
        menuGridCell.textLabel.text = "Fastest US"
        return menuGridCell
    }
    
    private func fastestUKCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        menuGridCell.iconView.image = R.image.gb()
        menuGridCell.decoratorView.image = R.image.topButtonRocketSmall()
        menuGridCell.textLabel.text = "Fastest UK"
        return menuGridCell
    }

    private func serverListCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        menuGridCell.iconView.image = R.image.headerIconAccount() // TODO get the correct icon
        menuGridCell.textLabel.text = "Servers"
        return menuGridCell
    }

    private func locationCell(indexPath: IndexPath, collectionView: UICollectionView, action: ButtonAction) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        
        if let server = action.vpnServerOption.getServer() {
            menuGridCell.iconView.image = UIImage(named: (server.country.lowercased()))
            
            let nameComponents = server.name.components(separatedBy: ",")
            menuGridCell.textLabel.text = nameComponents.first
        }
        
        if action.favorite {
            menuGridCell.decoratorView.image = R.image.topButtonStarSmall()
            menuGridCell.decoratorBgView.isHidden = false
        }
        else if action.recent {
            menuGridCell.decoratorView.image = R.image.topButtonRocketSmall()
            menuGridCell.decoratorBgView.isHidden = false
        }
        
        return menuGridCell
    }
    
    func buttonActionForCellAt(indexPath: IndexPath) -> ButtonAction {
        return buttonActions[indexPath.item]
    }
    
    private func locationButtonActionsByPriority(count: Int) -> [ButtonAction] {
        let realm = try! Realm()
        
        var regions = [Region]()
        var regionButtonActions = [ButtonAction]()
        
        let favorites = realm.objects(Region.self).filter("isFavorite = true").sorted(byKeyPath: "lastConnectedDate", ascending: false)

        for favorite in favorites {
            regions.append(favorite)
            let option = VPNServerOption(findServer: {(nil) -> Region? in return favorite }, type: .Server)
            regionButtonActions.append(ButtonAction(type: .SavedServer, favorite: true, recent: false, vpnServerOption: option))
            
            if regions.count == count {
                break;
            }
        }
        
        let notFavoritePredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "isFavorite = true"))
        let notDeveloperPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "level = 'developer'"))
        let authorizedPredicate = NSPredicate(format: "authorized = true")
        
        if regions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "lastConnectedDate = %@", Date(timeIntervalSince1970: 1) as CVarArg)))
            predicates.append(notDeveloperPredicate)
            
            let recent = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "lastConnectedDate", ascending: false)
            
            for region in recent {
                regions.append(region)
                let option = VPNServerOption(findServer: {(nil) -> Region? in return region }, type: .Server)
                regionButtonActions.append(ButtonAction(type: .SavedServer, favorite: false, recent: true, vpnServerOption: option))
                
                if regions.count == count {
                    break;
                }
            }
        }
        
        if regions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(notDeveloperPredicate)
            predicates.append(authorizedPredicate)
            
            // exclude the regions already added
            let regionIds = regions.map({ (region) -> String in
                region.id
            })
            predicates.append(NSPredicate(format: "NOT id IN %@", regionIds))
            
            let closest = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
            
            for region in closest {
                regions.append(region)
                let option = VPNServerOption(findServer: {(nil) -> Region? in return region }, type: .Server)
                regionButtonActions.append(ButtonAction(type: .SavedServer, favorite: false, recent: false, vpnServerOption: option))
                
                if regions.count == count {
                    break;
                }
            }
        }
        
        return regionButtonActions
    }
}

