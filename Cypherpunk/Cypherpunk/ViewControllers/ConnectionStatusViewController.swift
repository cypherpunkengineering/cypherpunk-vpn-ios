//
//  ConnectionStatusViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

class ConnectionStatusViewController: UITableViewController {
    
    @IBOutlet weak var connectionTimeLabelButton: UIButton!
    
    @IBOutlet weak var originalIPAddressLabel: UILabel!
    @IBOutlet weak var originalLocaleLabelButton: UIButton!

    @IBOutlet weak var disconnectedLabel: UILabel!
    @IBOutlet weak var connectedTimeView: UIView!
    @IBOutlet weak var newIPAddressLabel: UILabel!
    @IBOutlet weak var newLocalLabelButton: UIButton!
    
    @IBOutlet weak var originalPointCircleView: UIView!
    @IBOutlet weak var newPointCircleView: UIView!
    
    @IBOutlet weak var newPointCircleCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var newPointCircleCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var originalPointCircleCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var originalPointCircleCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linePathView: LinePathView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        originalPointCircleCenterXConstraint.constant = -27
        originalPointCircleCenterYConstraint.constant = 18
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Connection Status"

        let status = NEVPNManager.shared().connection.status
        if status == .connected {
            connectedTimeView.isHidden = false
            disconnectedLabel.isHidden = true
        } else {
            connectedTimeView.isHidden = true
            disconnectedLabel.isHidden = false
        }
        let statusState = mainStore.state.statusState
        self.originalIPAddressLabel.text = statusState.originalIPAddress ?? "---.---.---.---"
        self.newIPAddressLabel.text = statusState.newIPAddress ?? "---.---.---.---"
        
        self.originalLocaleLabelButton.setTitle(statusState.originalCountry ?? "", for: .normal)
        self.newLocalLabelButton.setTitle(statusState.newCountry ?? "", for: .normal)
        
        startTimer()
        mainStore.subscribe(self, selector: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
        mainStore.unsubscribe(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }

    var timerSource: DispatchSourceTimer!
    func startTimer() {
        let source = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main)
        
        source.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.nanoseconds(100))
        source.setEventHandler(handler: {
            let statusState = mainStore.state.statusState
            if let date = statusState.connectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                let difference = Date(timeIntervalSince1970: Date().timeIntervalSince(date))
                
                self.connectionTimeLabelButton.setTitle(formatter.string(from: difference), for: .normal)
            }
        })
        source.resume()
        timerSource = source
    }

    func cancelTimer() {
        if (timerSource != nil) {
            timerSource.cancel()
            timerSource = nil
        }
    }
    
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        if status == .connected || status == .disconnected {
            self.tableView.reloadData()
        }
    }

    
    @IBAction func changeIPAddressAction(_ sender: AnyObject) {
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let status = NEVPNManager.shared().connection.status
        if status == .connected {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return 4
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

}

import ReSwift
extension ConnectionStatusViewController: StoreSubscriber {

    func newState(state: AppState) {
        let statusState = state.statusState
        self.originalIPAddressLabel.text = statusState.originalIPAddress ?? "---.---.---.---"
        self.newIPAddressLabel.text = statusState.newIPAddress ?? "---.---.---.---"
        self.originalLocaleLabelButton.setTitle(statusState.originalCountry ?? "", for: .normal)
        self.newLocalLabelButton.setTitle(statusState.newCountry ?? "", for: .normal)
        
        if statusState.originalLatitude != nil && statusState.originalLongitude != nil {
            let pointX = statusState.originalLongitude! * 172 / 180
            originalPointCircleCenterXConstraint.constant = CGFloat(pointX)
            
            let pointY = statusState.originalLatitude! * 360 / 360 * -1
            originalPointCircleCenterYConstraint.constant = CGFloat(pointY)

            if statusState.newLatitude != nil && statusState.newLongitude != nil {
                let pointX = statusState.newLongitude! * 172 / 180
                newPointCircleCenterXConstraint.constant = CGFloat(pointX)
                
                let pointY = statusState.newLatitude! * 360 / 360 * -1
                newPointCircleCenterYConstraint.constant = CGFloat(pointY)
                let centerPoint = CGPoint(
                    x: (originalPointCircleView.center.x + newPointCircleView.center.x) / 2 ,
                    y: (originalPointCircleView.center.y + newPointCircleView.center.y) / 2
                )
                
                let controlPoint = CGPoint(
                    x: centerPoint.x + (newPointCircleView.center.y - originalPointCircleView.center.y) / 4,
                    y: centerPoint.y + (newPointCircleView.center.x - originalPointCircleView.center.x) / 4
                )
                
                self.linePathView.startPoint = originalPointCircleView.center
                self.linePathView.endPoint = newPointCircleView.center
                self.linePathView.controlPoint = controlPoint
                self.linePathView.setNeedsDisplay()
            }

        }


    }
}
