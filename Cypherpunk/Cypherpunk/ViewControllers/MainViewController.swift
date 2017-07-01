//
//  MainViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/24/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import Cartography
import simd
import RealmSwift
import NetworkExtension
import ReSwift
import TinySwift

class MainViewController: UIViewController, StoreSubscriber, VPNSwitchDelegate {
    
    var topBarView: UIView
    var bottomBorderLayer: CALayer
    var mapImageView: MapImageView
    var vpnSwitch: VPNSwitch
    var locationSelectorButton: LocationButton
    var locationSelectorVC: LocationSelectorViewController?
    var statusTitleLabel = UILabel()
    var statusLabel = UILabel()
    let leftButton = AccountButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    let rightButton = ConfigurationButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var locationButtonConstraintGroup: ConstraintGroup?
    
    required init?(coder aDecoder: NSCoder) {
        self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 70.0))
        self.topBarView.backgroundColor = UIColor.aztec
        
        self.bottomBorderLayer = CALayer()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: 0, width: 200.0, height: 1)
        self.bottomBorderLayer.backgroundColor = UIColor.greenVogue.cgColor
        self.topBarView.layer.addSublayer(self.bottomBorderLayer)
        
        self.mapImageView = MapImageView()
        
        self.vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        self.locationSelectorButton = LocationButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // listen for VPN status changes
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(vpnStatusChanged(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        notificationCenter.addObserver(self, selector: #selector(regionsUpdated(_:)), name: regionUpdateNotification, object: nil)
        
        
        // Add gradient layer for gradient background color
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor(hex: "#0F2125")!.cgColor, UIColor(hex: "#004444")!.cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)

        // add map image view
        self.view.addSubview(self.mapImageView)
        
        self.view.addSubview(self.topBarView)
        constrain(self.view, self.topBarView) { parentView, childView in
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
            childView.top == parentView.top
            childView.height == 64.0
        }
        
        let logoImageView = UIImageView(image: R.image.headerIconLogo())
        self.topBarView.addSubview(logoImageView)
        constrain(self.topBarView, logoImageView) { parentView, childView in
            childView.centerX == parentView.centerX
            childView.top == parentView.top + 32
        }
        
        self.leftButton.addTarget(self, action: #selector(openOrCloseAccountAction(_:)), for: .touchUpInside)
        self.view.addSubview(self.leftButton)
        constrain(self.view, self.leftButton) { parentView, childView in
            childView.leading == parentView.leading
            childView.top == parentView.top + 36.0
            childView.height == 60.0
            childView.width == 60.0
        }
        
        self.rightButton.addTarget(self, action: #selector(openOrCloseConfigurationAction(_:)), for: .touchUpInside)
        self.view.addSubview(self.rightButton)
        constrain(self.view, self.rightButton) { parentView, childView in
            childView.trailing == parentView.trailing
            childView.top == parentView.top + 36.0
            childView.height == 60.0
            childView.width == 60.0
        }
        
        self.view.addSubview(self.vpnSwitch)
        constrain(self.view, self.vpnSwitch) { parentView, childView in
            childView.bottom == parentView.centerY - 75
            childView.height == 50.0
            childView.width == 100.0
            childView.centerX == parentView.centerX
        }
        self.vpnSwitch.delegate = self
        
        self.view.addSubview(self.statusLabel)
        self.statusLabel.font = R.font.dosisMedium(size: 18)
        self.statusLabel.text = "DISCONNECTED"
        self.statusLabel.textColor = UIColor.white
        constrain(self.view, self.statusLabel) { parentView, childView in
            childView.bottom == parentView.centerY
            childView.centerX == parentView.centerX
        }
        
        statusTitleLabel.textColor = UIColor.greenyBlue
        statusTitleLabel.text = "STATUS"
        statusTitleLabel.font = R.font.dosisMedium(size: 10)
        self.view.addSubview(statusTitleLabel)
        constrain(self.view, statusTitleLabel, self.statusLabel) { parentView, childView, statusLabel in
            childView.leading == statusLabel.leading
            childView.bottom == statusLabel.top
        }
        
        self.view.addSubview(self.locationSelectorButton)
        locationButtonConstraintGroup = constrain(self.view, self.locationSelectorButton) { parentView, childView in
            // do not constrain the width of the location button, it needs to flex based on the text shown
            childView.top == parentView.centerY + 100
            childView.height == 40.0
            childView.centerX == parentView.centerX
        }
        self.locationSelectorButton.delegate = self
        
        
        // set the map and location button based on the last selected region
        if let lastSelected = mainStore.state.regionState.lastSelectedRegionId {
            let realm = try! Realm()
            if let selectedRegion = realm.object(ofType: Region.self, forPrimaryKey: lastSelected) {
                self.mapImageView.zoomToRegion(region: selectedRegion)
                self.locationSelectorButton.location = selectedRegion
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VPNConfigurationCoordinator.load {_ in
            let status = NEVPNManager.shared().connection.status
            self.updateView(vpnStatus: status)
        }
        
        mainStore.subscribe(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: self.topBarView.frame.height - 1, width: self.topBarView.frame.width, height: 1)
    }
    

    @IBAction func openOrCloseConfigurationAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseConfigurationNotification, object: nil)
    }
    @IBAction func openOrCloseAccountAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: kOpenOrCloseAccountNotification, object: nil)
    }
    
    @IBAction func showLocationSelector(_ sender: AnyObject) {
        self.locationSelectorVC = LocationSelectorViewController(nibName: "LocationSelectorViewController", bundle: nil)
        self.locationSelectorVC?.delegate = self
        
        self.addChildViewController(self.locationSelectorVC!)
        
        self.locationSelectorVC?.view.alpha = 0.0
        self.view.addSubview((self.locationSelectorVC?.view)!)
        self.view.bringSubview(toFront: self.leftButton)
        self.view.bringSubview(toFront: self.rightButton)
        
        
        constrain(self.view, (self.locationSelectorVC?.view)!, self.topBarView) { parentView, childView, topBarView in
            childView.top == topBarView.bottom
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
            childView.bottom == parentView.bottom
        }
        
        UIView.animate(withDuration: 0.5) { 
            self.locationSelectorVC?.view.alpha = 1.0
            self.vpnSwitch.isHidden = true
            self.locationSelectorButton.isHidden = true
            self.statusTitleLabel.isHidden = true
            self.statusLabel.isHidden = true
            self.mapImageView.isMarkerInBackground = true
        }
    }
    
    private func updateView(vpnStatus: NEVPNStatus) {
        var status = ""
        
        switch vpnStatus {
        case .invalid:
            status = "Invalid"
        case .connecting:
            status = "Connecting"
            self.vpnSwitch.isOn = true
        case .connected:
            status = "Connected"
        case .disconnecting:
            status = "Disconnecting"
        case .disconnected:
            status = "Disconnected"
        case .reasserting:
            status = "Reasserting"
        }
        
        self.statusLabel.text = status.uppercased()
        self.statusLabel.sizeToFit()
        
        if UIDevice.current.isSimulator {
            // TODO what should be done here
        }
    }
    
    func vpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        switch status {
        case .invalid:
            print("INVALID") // TODO
            break
        case .connected:
            vpnSwitch.isOn = true
        case .disconnected:
            vpnSwitch.isOn = false
        default:
            break
        }
        
        self.updateView(vpnStatus: status)
    }
    
    func regionsUpdated(_ notification: Notification) {
        self.mapImageView.drawLocationsOnMap()
    }
    
    func newState(state: AppState) {
        print("NEW STATE")
        // TODO: is there really no way to target specific property changes?
//        if let regionId = state.regionState.lastSelectedRegionId {
//            let realm = try! Realm()
//            if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
//                self.mapImageView.zoomToRegion(region: region)
//                self.locationSelectorButton.location = region
//            }
//        }
        
//        regionTitleLabel?.text = state.regionState.title
//        regionFlagImageView?.image = UIImage(named: state.regionState.countryCode.lowercased())?.withRenderingMode(.alwaysOriginal)
//        premiumLocationIconWidthConstraint?.constant = 0.0
//        devLocationIconWidthConstraint?.constant = 0.0
//        regionTrailingConstraint?.constant = 0.0
//        premiumLocationIconView?.isHidden = true
//        devLocationIconView?.isHidden = true
//        if state.regionState.level == "premium" {
//            premiumLocationIconWidthConstraint?.constant = 56.0
//            devLocationIconWidthConstraint?.constant = 56.0
//            regionTrailingConstraint?.constant = 32.0
//            premiumLocationIconView?.isHidden = false
//        } else if state.regionState.level == "developer" {
//            premiumLocationIconWidthConstraint?.constant = 25.0
//            devLocationIconWidthConstraint?.constant = 25.0
//            devLocationIconView?.isHidden = false
//        }
//        self.view.layoutIfNeeded()
    }
    
    // MARK: - VPNSwitchDelegate
    func stateChanged(on: Bool) {
        if UIDevice.current.isSimulator {
            mainStore.dispatch(RegionAction.connect)
            self.updateView(vpnStatus: .connected)
        }
        else {
            if on {
                VPNConfigurationCoordinator.connect()
            }
            else {
                VPNConfigurationCoordinator.disconnect()
            }
        }
    }
}

extension MainViewController: LocationSelectionDelegate {
    func dismissSelector() {
        showControls() {
            // reset the zoom just in case they didn't select anything
            if let regionId = mainStore.state.regionState.lastSelectedRegionId {
                self.mapImageView.zoomToRegion(regionId: regionId)
            }
        }
    }
    
    func scrolledTo(location: Region) {
        self.mapImageView.zoomToRegion(region: location)
    }
    
    func locationSelected(location: Region) {
        showControls() {
            self.mapImageView.zoomToRegion(region: location)
            self.locationSelectorButton.location = location
        }
    }
    
    private func showControls(_ completion: (() -> Void)? = nil) {
        self.locationSelectorVC?.willMove(toParentViewController: nil)
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.locationSelectorVC?.view.removeFromSuperview()
            
            self.vpnSwitch.isHidden = false
            self.locationSelectorButton.isHidden = false
            self.statusTitleLabel.isHidden = false
            self.statusLabel.isHidden = false
            
            self.mapImageView.isMarkerInBackground = false
        }) { (completed) in
            self.locationSelectorVC?.removeFromParentViewController()
            if let block = completion {
                block()
            }
        }
    
        self.locationSelectorVC = nil
    }
}

extension MainViewController: LocationButtonDelgate {
    func buttonPressed() {
        showLocationSelector(self)
    }
}
