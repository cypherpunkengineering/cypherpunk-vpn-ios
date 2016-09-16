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
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NEVPNStatusDidChangeNotification,
            object: nil
        )
        
        originalPointCircleCenterXConstraint.constant = -27
        originalPointCircleCenterYConstraint.constant = 18
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.title = "Connection Status"

        let status = NEVPNManager.sharedManager().connection.status
        if status == .Connected {
            connectedTimeView.hidden = false
            disconnectedLabel.hidden = true
        } else {
            connectedTimeView.hidden = true
            disconnectedLabel.hidden = false
        }
        let statusState = mainStore.state.statusState
        self.originalIPAddressLabel.text = statusState.originalIPAddress ?? "---.---.---.---"
        self.newIPAddressLabel.text = statusState.newIPAddress ?? "---.---.---.---"
        
        self.originalLocaleLabelButton.setTitle(statusState.originalCountry ?? "", forState: .Normal)
        self.newLocalLabelButton.setTitle(statusState.newCountry ?? "", forState: .Normal)
        
        startTimer()
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
        mainStore.unsubscribe(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }

    var timerSource: dispatch_source_t!
    func startTimer() {
        let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        
        if source != nil {
            let secondsToFire: Double = 0.1
            let now = dispatch_time(DISPATCH_TIME_NOW, Int64(secondsToFire * Double(NSEC_PER_SEC)))
            let interval = UInt64(secondsToFire * Double(NSEC_PER_SEC))
            dispatch_source_set_timer(source, now, interval, (1 * NSEC_PER_SEC) / 10)
            dispatch_source_set_event_handler(source, {
                let statusState = mainStore.state.statusState
                if let date = statusState.connectedDate {
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "HH:mm:ss"
                    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                    let difference = NSDate(timeIntervalSince1970: NSDate().timeIntervalSinceDate(date))
                    
                    self.connectionTimeLabelButton.setTitle(formatter.stringFromDate(difference), forState: .Normal)
                }
            })
            dispatch_resume(source)
        }
        timerSource = source
    }

    func cancelTimer() {
        if (timerSource != nil) {
            dispatch_source_cancel(timerSource)
            timerSource = nil
        }
    }
    
    func didChangeVPNStatus(notification: NSNotification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        if status == .Connected || status == .Disconnected {
            self.tableView.reloadData()
        }
    }

    
    @IBAction func changeIPAddressAction(sender: AnyObject) {
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let status = NEVPNManager.sharedManager().connection.status
        if status == .Connected {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return 4
        }
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

}

import ReSwift
extension ConnectionStatusViewController: StoreSubscriber {
    func newState(state: AppState) {
        let statusState = state.statusState
        self.originalIPAddressLabel.text = statusState.originalIPAddress ?? "---.---.---.---"
        self.newIPAddressLabel.text = statusState.newIPAddress ?? "---.---.---.---"
        self.originalLocaleLabelButton.setTitle(statusState.originalCountry ?? "", forState: .Normal)
        self.newLocalLabelButton.setTitle(statusState.newCountry ?? "", forState: .Normal)
        
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
