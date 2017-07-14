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
    var gradientLayer: CAGradientLayer
    var mapImageView: MapImageView
    var vpnSwitch: VPNSwitch
    var locationSelectorButton: LocationButton
    var locationSelectorVC: LocationSelectorViewController?
    var statusTitleLabel = UILabel()
    var statusLabel = UILabel()
    let leftButton = AccountButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    let rightButton = ConfigurationButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var locationButtonConstraintGroup: ConstraintGroup?
    
    var lastSelectedRegionId: String?
    
    required init?(coder aDecoder: NSCoder) {
        self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 70.0))
        self.topBarView.backgroundColor = UIColor.aztec
        
        self.bottomBorderLayer = CALayer()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: 0, width: 200.0, height: 1)
        self.bottomBorderLayer.backgroundColor = UIColor.greenVogue.cgColor
        self.topBarView.layer.addSublayer(self.bottomBorderLayer)
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.colors = [UIColor(hex: "#0F2125")!.cgColor, UIColor(hex: "#004444")!.cgColor]
        
        self.mapImageView = MapImageView()
        
        self.vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        self.locationSelectorButton = LocationButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStore.subscribe(self)
        
        // listen for VPN status changes
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(vpnStatusChanged(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
//        notificationCenter.addObserver(
//            self,
//            selector: #selector(vpnCongfigurationChanged(_:)),
//            name: NSNotification.Name.NEVPNConfigurationChange,
//            object: nil
//        )
        notificationCenter.addObserver(self, selector: #selector(regionsUpdated(_:)), name: regionUpdateNotification, object: nil)
        
        
        // Add gradient layer for gradient background color
        self.gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer, at: 0)

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
//        self.vpnSwitch.delegate = self
        
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
        if let regionId = mainStore.state.regionState.lastSelectedRegionId {
            let realm = try! Realm()
            if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                self.mapImageView.zoomToRegion(region: region)
                self.locationSelectorButton.location = region
                self.view.setNeedsDisplay()
                self.view.setNeedsLayout()
                
                self.lastSelectedRegionId = regionId
            }
        }
        
        // HACK: This is to temporarily force everything to IKEv2
        if mainStore.state.settingsState.vpnProtocolMode == .IPSec {
            mainStore.dispatch(SettingsAction.vpnProtocolMode(value: .IKEv2))
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
            self.vpnSwitch.isOn = VPNConfigurationCoordinator.isProfileEnabled
            self.vpnSwitch.delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.vpnSwitch.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bottomBorderLayer.frame = CGRect(x: 0, y: self.topBarView.frame.height - 1, width: self.topBarView.frame.width, height: 1)
        self.gradientLayer.frame = self.view.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let locationSelector = self.locationSelectorVC {
            // forcing the view to redraw and recompute size of cells
            locationSelector.view.setNeedsLayout()
            locationSelector.view.setNeedsDisplay()
            locationSelector.reloadLocations()
        }
        
        self.mapImageView.setNeedsLayout()
        self.mapImageView.setNeedsDisplay()
        self.view.setNeedsDisplay()
        self.view.setNeedsLayout()
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
    
    private func updateViewWithLastSeclectedRegion() {
        if let regionId = mainStore.state.regionState.lastSelectedRegionId {
            if self.lastSelectedRegionId != regionId {
                let realm = try! Realm()
                if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                    self.mapImageView.zoomToRegion(region: region)
                    self.locationSelectorButton.location = region
                    self.view.setNeedsDisplay()
                    
                    self.lastSelectedRegionId = regionId
                }
            }
        }
    }
    
    func vpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        self.updateView(vpnStatus: status)
    }
    
//    func vpnCongfigurationChanged(_ notification: Notification) {
//
//    }
    
    func regionsUpdated(_ notification: Notification) {
        self.mapImageView.drawLocationsOnMap()
    }
    
    func newState(state: AppState) {
        print("NEW STATE")
        // TODO: is there really no way to target specific property changes?
        updateViewWithLastSeclectedRegion()
    }
    
    // MARK: - VPNSwitchDelegate
    func stateChanged(on: Bool) {
        if UIDevice.current.isSimulator {
            mainStore.dispatch(RegionAction.connect)
            self.updateView(vpnStatus: .connected)
        }
        else {
            VPNConfigurationCoordinator.isProfileEnabled = on
        }
    }
}

extension MainViewController: LocationSelectionDelegate {
    func dismissSelector() {
        showControls() {
            // check if the user actually selected a new region, if not reset to last selected
            if let regionId = mainStore.state.regionState.lastSelectedRegionId {
                if self.lastSelectedRegionId == regionId {
                    self.mapImageView.zoomToRegion(regionId: regionId)
                }
            }
        }
    }
    
    func scrolledTo(location: Region) {
        self.mapImageView.zoomToRegion(region: location)
    }
    
    func locationSelected(location: Region) {
        showControls() // the state change will handle the map movement
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
