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
        initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    private func initialize() {
        layoutType = determineButtonLayoutType()
        createVPNServerOptions()
        
        // listen for notifictions
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegionUpdateNotification), name: regionUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegionSelectedNotification), name: NSNotification.Name(rawValue: regionSelectedNotificationKey), object: nil)
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
    
    func handleRegionUpdateNotification() {
        vpnServerOptions = createUserLocationsOptions(vpnServerOptions)
        updateLocationButtons()
    }
    
    func handleRegionSelectedNotification() {
        
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
        
        if layoutType == .Seven || layoutType == .Five {
            // need to find 2 locations to show
            newVPNServerOptions = createUserLocationsOptions(newVPNServerOptions)
        }
        
        vpnServerOptions = newVPNServerOptions
    }
    
    private func createUserLocationsOptions(_ vpnOptionsDict: [VPNServerOptionType: VPNServerOption]) -> [VPNServerOptionType: VPNServerOption] {
        var modifiedVPNOptions = vpnOptionsDict
        
        let regions = ConnectionHelper.getUserLocations(count: 2)
        
        let noopServerOption = VPNServerOption(findServer: {(nil) -> Region? in return nil }, type: .Server)
        
        if let region = regions.first {
            let option = VPNServerOption(findServer: {(nil) -> Region? in return region }, type: .Server)
            modifiedVPNOptions[.Location1] = option
        }
        else {
            modifiedVPNOptions[.Location1] = noopServerOption
        }

        if regions.count > 1 {
            let option = VPNServerOption(findServer: {(nil) -> Region? in return regions[1] }, type: .Server)
            modifiedVPNOptions[.Location2] = option
        }
        else {
            modifiedVPNOptions[.Location2] = noopServerOption
        }
        
        return modifiedVPNOptions
    }
    
    func updateLocationButtons() {
        // empty for base class, subclasses can override if neccessary
    }
    
    func connectToServer(vpnServerOptionType: VPNServerOptionType) {
        if let option = vpnServerOptions[vpnServerOptionType] {
            vpnStateController.connect(newOption: option)
        }
    }
    
    func showServerList() {
        delegate?.showServerList()
    }
    
    func populateButtonViewWithLocationOption(option: VPNServerOption, view: MainButtonView) {
        if let server = option.getServer() {
            view.iconView.image = UIImage(named: server.country.lowercased())
            
            let nameComponents = server.name.components(separatedBy: ",")
            view.textLabel.text = nameComponents.first
        }
        else {
            view.iconView.image = nil
            view.textLabel.text = ""
        }
    }
}
