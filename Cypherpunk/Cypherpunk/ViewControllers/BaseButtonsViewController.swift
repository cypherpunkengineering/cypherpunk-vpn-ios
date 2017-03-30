//
//  BaseButtonsViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/27/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import RealmSwift

enum MainButtonLayoutType {
    case Seven
    case Five
    case Three
}

protocol ButtonsDelegate {
    func showServerList()
}

class BaseButtonsViewController: UIViewController {
    var delegate: ButtonsDelegate?
    
    let vpnStateController = VPNStateController.sharedInstance
    
    private var layoutType = MainButtonLayoutType.Seven
    
    var vpnServerOptions = [VPNServerOptionType: VPNServerOption]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutType = determineButtonLayoutType()
        createVPNServerOptions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func determineButtonLayoutType() -> MainButtonLayoutType {
        if (UIScreen.main.bounds.height < 568) {
            // assume iPhone 4s size
            return .Three
        }
        else if (UIScreen.main.bounds.height < 667) {
            // iPhone 5/5s size
            return .Five
        }
        else {
            // iPhone 6 and above
            return .Seven
        }
    }
    
    private func createVPNServerOptions() {
        var newVPNServerOptions = [VPNServerOptionType: VPNServerOption]()
        
        // create cypherplay option
        let cypherplayServerOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .CypherPlay)
        cypherplayServerOption.cypherplay = true
        
        let fastestServerOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .Fastest)
        
        let fastestUSOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .FastestUS, country: "US")
        let fastestUKOption = VPNServerOption(findServer: ConnectionHelper.findFastest, type: .FastestUK, country: "GB")
        
        newVPNServerOptions[.CypherPlay] = cypherplayServerOption
        newVPNServerOptions[.Fastest] = fastestServerOption
        newVPNServerOptions[.FastestUS] = fastestUSOption
        newVPNServerOptions[.FastestUK] = fastestUKOption
        
        if layoutType == .Seven {
            // need to find 2 locations to show
            newVPNServerOptions = createUserLocationsOptions(newVPNServerOptions)
        }
        
        vpnServerOptions = newVPNServerOptions
    }
    
    private func createUserLocationsOptions(_ vpnOptionsDict: [VPNServerOptionType: VPNServerOption]) -> [VPNServerOptionType: VPNServerOption] {
        var modifiedVPNOptions = vpnOptionsDict
        
        let count = 2
        
        let noopServerOption = VPNServerOption(findServer: {(nil) -> Region? in return nil }, type: .Server)
        
        let realm = try! Realm()
        var serverOptions = [VPNServerOption]()
        
        let favorites = realm.objects(Region.self).filter("isFavorite = true").sorted(byKeyPath: "lastConnectedDate", ascending: false)

        // check for favorites
        for favorite in favorites {
            let option = VPNServerOption(findServer: {(nil) -> Region? in return favorite }, type: .Server)
            serverOptions.append(option)

            if serverOptions.count == count {
                break;
            }
        }
        
        let notFavoritePredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "isFavorite = true"))
        let notDeveloperPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "level = 'developer'"))
        let authorizedPredicate = NSPredicate(format: "authorized = true")

        // check for recently connected
        if serverOptions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "lastConnectedDate = %@", Date(timeIntervalSince1970: 1) as CVarArg)))
            predicates.append(notDeveloperPredicate)

            let recent = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).sorted(byKeyPath: "lastConnectedDate", ascending: false)

            for region in recent {
                let option = VPNServerOption(findServer: {(nil) -> Region? in return region }, type: .Server)
                serverOptions.append(option)

                if serverOptions.count == count {
                    break;
                }
            }
        }

        // if there weren't enough recently connected or favorites, just find closest servers
        if serverOptions.count < count {
            var predicates = [NSPredicate]()
            predicates.append(notFavoritePredicate)
            predicates.append(notDeveloperPredicate)
            predicates.append(authorizedPredicate)

            // exclude the regions already added
            let regionIds = serverOptions.map({ (serverOption) -> String in
                (serverOption.getServer()?.id)!
            })
            predicates.append(NSPredicate(format: "NOT id IN %@", regionIds))

            let closest = realm.objects(Region.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))

            for region in closest {
                let option = VPNServerOption(findServer: {(nil) -> Region? in return region }, type: .Server)
                serverOptions.append(option)
                
                if serverOptions.count == count {
                    break;
                }
            }
        }
        
        if let firstOption = serverOptions.first {
            modifiedVPNOptions[.Location1] = firstOption
        }
        else {
            modifiedVPNOptions[.Location1] = noopServerOption
        }
        
        if serverOptions.count > 1 {
            modifiedVPNOptions[.Location2] = serverOptions[1]
        }
        else {
            modifiedVPNOptions[.Location2] = noopServerOption
        }
        
        return modifiedVPNOptions
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func connectToServer(vpnServerOptionType: VPNServerOptionType) {
        if let option = vpnServerOptions[vpnServerOptionType] {
            vpnStateController.connect(newOption: option)
        }
    }
    
    func showServerList() {
        delegate?.showServerList()
    }
}
