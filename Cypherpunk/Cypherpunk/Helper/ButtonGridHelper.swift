//
//  ButtonGridHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 1/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

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
    var server: String
}

final class ButtonGridHelper {
    private var buttonActions : [ButtonAction]
    
    // Can't init is singleton
    private init() {
        buttonActions = [ButtonAction]()
        createButtonActions()
    }
    
    //MARK: Shared Instance
    static let sharedInstance: ButtonGridHelper = ButtonGridHelper()
    
    private func createButtonActions() {
        buttonActions.removeAll() // clear out any actions
        let buttonCount = numberOfButtonsForGrid()
        
        // all layouts have a cyperplay, fastest, and server list
        let cyperplayAction = ButtonAction(type: .CypherPlay, server: "")
        buttonActions.append(cyperplayAction) // this is always first
        
        let fastestAction = ButtonAction(type: .Fastest, server: "")
        
        let serverList = ButtonAction(type: .ServerList, server: "")
        
        if (buttonCount == 3) {
            buttonActions.append(fastestAction)
            buttonActions.append(serverList)
        }
        else if (buttonCount == 6) {
            buttonActions.append(fastestAction)
            buttonActions.append(fastestAction)
            buttonActions.append(fastestAction)
            buttonActions.append(fastestAction)
        }
        else if (buttonCount == 7) {
            buttonActions.append(fastestAction)
        }
        
        // server list action should always be last
        buttonActions.append(serverList)
    }
    
    func numberOfButtonsForGrid() -> Int {
        // TODO: check idiom for iPad
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            return 3
        }
        else if (UIScreen.main.bounds.height < 667) {
            // iPhone 5/5s size
            return 6
        }
        else {
            // iPhone 6 and above
            return 7
        }
    }
    
    func heightForButtonAt(index: Int) -> Int {
        // TODO: check idiom for iPad
        if (index == 0 && UIScreen.main.bounds.height > 568) {
            // iPhone 6 and above
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
            return Int(screenWidth) / 4
        }
        else {
            return Int(screenWidth) / 3
        }
    }

    func sizeForButton(index: Int) -> CGSize {
        return CGSize(width: widthForButtonAt(index: index), height: heightForButtonAt(index: index))
    }

    func setupButtonAt(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        // TODO: check idiom for iPad
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            return cellForThreeButtonGrid(indexPath: indexPath, collectionView: collectionView)
        }
        else if (UIScreen.main.bounds.height < 667) {
            // iPhone 5/5s size
            return cellForSixButtonGrid(indexPath: indexPath, collectionView: collectionView)
        }
        else {
            // iPhone 6 and above
            return cellForSevenButtonGrid(indexPath: indexPath, collectionView: collectionView)
        }
    }

    private func cellForThreeButtonGrid(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        var cell : UICollectionViewCell? = nil

        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CypherPlayCell", for: indexPath)
        case 1:
            cell = fastestCell(indexPath: indexPath, collectionView: collectionView)
        default:
            cell = serverListCell(indexPath: indexPath, collectionView: collectionView)
        }

        return cell!
    }

    private func cellForSixButtonGrid(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        var cell : UICollectionViewCell? = nil

        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CypherPlayCell", for: indexPath)
        case 1:
            cell = locationCell(indexPath: indexPath, collectionView: collectionView)
        case 2:
            cell = fastestCell(indexPath: indexPath, collectionView: collectionView)
        default:
            cell = serverListCell(indexPath: indexPath, collectionView: collectionView)
        }

        return cell!
    }

    private func cellForSevenButtonGrid(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        var cell : UICollectionViewCell? = nil

        switch indexPath.item {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CypherPlayCell", for: indexPath)
        case 1:
            cell = fastestCell(indexPath: indexPath, collectionView: collectionView)
        default:
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

    private func serverListCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
//        menuGridCell.iconView.image = R.image.headerIconLogo() // TODO get the correct icon
        menuGridCell.iconView.image = nil
        menuGridCell.textLabel.text = "Servers"
        return menuGridCell
    }

    private func locationCell(indexPath: IndexPath, collectionView: UICollectionView) -> MenuGridCollectionViewCell {
        let menuGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuGridCell", for: indexPath) as! MenuGridCollectionViewCell
        //        menuGridCell.iconView.image = R.image.headerIconLogo() // TODO get the correct icon
        menuGridCell.iconView.image = R.image.us()
        menuGridCell.decoratorView.image = R.image.topButtonStarSmall()
        menuGridCell.decoratorBgView.isHidden = false
        menuGridCell.textLabel.text = "Atlanta"
        return menuGridCell
    }
    
    func buttonActionForCellAt(indexPath: IndexPath) -> ButtonAction {
        return buttonActions[indexPath.item]
    }
}

