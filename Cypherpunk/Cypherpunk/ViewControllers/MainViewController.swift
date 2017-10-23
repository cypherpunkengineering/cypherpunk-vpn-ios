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

class MainViewController: UIViewController, StoreSubscriber {
    
    var topBarView: UIView
    var bottomBorderLayer: CALayer
    var gradientLayer: CAGradientLayer
    var mapImageView: MapImageView
    var vpnSwitchAnimationView: VPNSwitchAnimationView
    var locationSelectorButton: LocationButton
    var locationSelectorVC: LocationSelectorViewController?
    var statusTitleLabel = UILabel()
    var statusLabel = UILabel()
    var statusDetailLabel = UILabel()
    let leftButton = AccountButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    let rightButton = ConfigurationButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var locationButtonConstraintGroup: ConstraintGroup?
    
    var lastSelectedRegionId: String?
    var lastCypherplayEnabled: Bool = false
    
    var lastVPNEnabled: Bool = false
    
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
        
        self.vpnSwitchAnimationView = VPNSwitchAnimationView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
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
//        notificationCenter.addObserver(
//            self,
//            selector: #selector(vpnCongfigurationChanged(_:)),
//            name: NSNotification.Name.NEVPNConfigurationChange,
//            object: nil
//        )
        notificationCenter.addObserver(self, selector: #selector(regionsUpdated(_:)), name: regionUpdateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showLocationSelector(_:)), name: ShortcutHelper.showLocationListNotification, object: nil)
        
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
        
        self.view.addSubview(self.vpnSwitchAnimationView)
        constrain(self.view, self.vpnSwitchAnimationView) { parentView, childView in
            childView.bottom == parentView.centerY - 75
            childView.centerX == parentView.centerX
            childView.width == parentView.width
            childView.height == self.vpnSwitchAnimationView.vpnSwitch.bounds.height + 15
        }
        self.vpnSwitchAnimationView.vpnSwitchDelegate = self
        
        statusDetailLabel.textColor = UIColor.seafoamBlue
        statusDetailLabel.text = "Status details"
        statusDetailLabel.font = R.font.dosisRegular(size: 14)
        self.view.addSubview(self.statusDetailLabel)
        constrain(self.view, self.statusDetailLabel) { parentView, childView in
            childView.bottom == parentView.centerY + 35
            childView.centerX == parentView.centerX
            childView.height == 20
        }
        self.statusDetailLabel.isHidden = true // hide this for now, may use later
        
        self.view.addSubview(self.statusLabel)
        self.statusLabel.font = R.font.dosisMedium(size: 18)
        self.statusLabel.text = "DISCONNECTED"
        self.statusLabel.textColor = UIColor.white
        constrain(self.view, self.statusLabel, self.statusDetailLabel) { parentView, childView, statusDetailLabel in
            childView.bottom == statusDetailLabel.top - 10
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
            
            if UI_USER_INTERFACE_IDIOM() == .phone && UIScreen.main.bounds.height < 600 {
                childView.bottom == parentView.bottom - 50
            }
            else {
                childView.bottom == parentView.bottom - 100
            }
            childView.height == 40.0
            childView.centerX == parentView.centerX
        }
        self.locationSelectorButton.delegate = self
        
        self.lastVPNEnabled = VPNConfigurationCoordinator.isEnabled
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
            
            self.vpnSwitchAnimationView.vpnSwitch.delegate = self
        }
        
        mainStore.subscribe(self) { $0.select { state in state.regionState } }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.vpnSwitchAnimationView.vpnSwitch.delegate = nil
        mainStore.unsubscribe(self)
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
        
        self.mapImageView.isMapInBackground = true
//        UIView.animate(withDuration: 0.5) { 
            self.locationSelectorVC?.view.alpha = 1.0
            self.vpnSwitchAnimationView.isHidden = true
            self.locationSelectorButton.isHidden = true
            self.statusTitleLabel.isHidden = true
            self.statusLabel.isHidden = true
            self.statusDetailLabel.isHidden = true
//        }
    }
    
    private func updateView(vpnStatus: NEVPNStatus) {
        var status = ""
        var statusDetail = ""
        
        if VPNConfigurationCoordinator.isEnabled {
            switch vpnStatus {
            case .invalid:
                status = "Invalid"
                statusDetail = "VPN configuration error occurred"
                self.vpnSwitchAnimationView.cancelConnectAnimation()
            case .connecting:
                status = "Connecting..."
                self.vpnSwitchAnimationView.beginConnectAnimation()
            case .connected:
                status = "Connected"
                if let ssid = ConnectionHelper.currentWifiSSID(), !ConnectionHelper.currentWifiNetworkTrusted() {
                    statusDetail = "\(ssid) is not a trusted network"
                }
                else if ConnectionHelper.connectedToCellular() && !mainStore.state.settingsState.isTrustCellularNetworks {
                    statusDetail = "Cellular networks are not trusted"
                }
                self.vpnSwitchAnimationView.transitionToConnectedAnimation()
            case .disconnecting:
                status = "Disconnecting..."
                self.vpnSwitchAnimationView.cancelConnectAnimation()
            case .disconnected:
                if ConnectionHelper.currentWifiNetworkTrusted() {
                    status = "Trusted"
                    statusDetail = "\(ConnectionHelper.currentWifiSSID()!) is a trusted network"
                }
                else if ConnectionHelper.connectedToCellular() && mainStore.state.settingsState.isTrustCellularNetworks {
                    status = "Disconnected"
                    statusDetail = "Cellular networks are trusted"
                }
                else {
                    status = "Disconnected"
                }
                self.vpnSwitchAnimationView.cancelConnectAnimation()
            case .reasserting:
//                status = "Reasserting"
                status = "Disconnected" // user won't know what this is, use disconneted
                self.vpnSwitchAnimationView.cancelConnectAnimation()
            }
        }
        else {
//            status = "Disabled"
            status = "Disconnected"
            self.vpnSwitchAnimationView.cancelConnectAnimation()
        }
        
        self.statusLabel.text = status.uppercased()
        self.statusLabel.sizeToFit()
        
        self.statusDetailLabel.text = statusDetail
        self.statusDetailLabel.sizeToFit()
        
//        self.vpnSwitchAnimationView.vpnSwitch.isOn = VPNConfigurationCoordinator.isEnabled //VPNConfigurationCoordinator.isConnected || VPNConfigurationCoordinator.isConnecting
        self.vpnSwitchAnimationView.vpnSwitch.isOn = VPNConfigurationCoordinator.isConnected || VPNConfigurationCoordinator.isConnecting
        
        print(status)
        
//        if UIDevice.current.isSimulator {
//            // TODO what should be done here
//        }
    }
    
    private func updateViewWithLastSeclectedRegion() {
        if let regionId = mainStore.state.regionState.lastSelectedRegionId {
            let cypherplayOn = mainStore.state.regionState.cypherplayOn
            if self.lastSelectedRegionId != regionId || self.lastCypherplayEnabled != cypherplayOn {
                let realm = try! Realm()
                if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                    cypherplayOn ? self.mapImageView.zoomOut() : self.mapImageView.zoomToRegion(region: region)
                    self.locationSelectorButton.setLocation(location: region, cypherplay: cypherplayOn)
                    self.view.setNeedsDisplay()

                    self.lastSelectedRegionId = regionId
                    self.lastCypherplayEnabled = cypherplayOn
                }
            }
            else {
                if !mainStore.state.regionState.cypherplayOn {
                    self.mapImageView.shiftMapToLeft()
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
    
    func newState(state: RegionState) {
        // TODO: is there really no way to target specific property changes?
        updateViewWithLastSeclectedRegion()
    }
}

extension MainViewController: LocationSelectionDelegate {
    func dismissSelector() {
        self.mapImageView.isMapInBackground = false
        self.mapImageView.shiftMapToLeft()
        showControls()
    }
    
    func locationSelected(location: Region) {
        self.mapImageView.isMapInBackground = false
        showControls() {
            ConnectionHelper.connectTo(region: location, cypherplay: false)
        }
    }
    
    func fastestSelected(cypherplay: Bool) {
        self.mapImageView.isMapInBackground = false
        showControls() {
            ConnectionHelper.connectToFastest(cypherplay: cypherplay)
        }
    }
    
    private func showControls(_ completion: (() -> Void)? = nil) {
        self.locationSelectorVC?.willMove(toParentViewController: nil)
        
//        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.locationSelectorVC?.view.removeFromSuperview()
            
            self.vpnSwitchAnimationView.isHidden = false
            self.locationSelectorButton.isHidden = false
            self.statusTitleLabel.isHidden = false
            self.statusLabel.isHidden = false
//            self.statusDetailLabel.isHidden = false
        
//            self.mapImageView.isMapInBackground = false
//        }) { (completed) in
            self.locationSelectorVC?.removeFromParentViewController()
            if let block = completion {
                block()
            }
//        }
    
        self.locationSelectorVC = nil
    }
}

extension MainViewController: LocationButtonDelgate {
    func buttonPressed() {
        showLocationSelector(self)
    }
}

extension MainViewController: VPNSwitchDelegate {
    func shouldChangeSwitchState() -> Bool {
        return true
    }

    func stateChanged(on: Bool) {
        ConnectionHelper.handleVPNStateChange(on: on)
    }
}
