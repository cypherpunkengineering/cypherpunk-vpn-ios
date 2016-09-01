//
//  SettingsStatusViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import NetworkExtension

class SettingsStatusViewController: UITableViewController, PageContent {

    var pageIndex: Int = 1
    
    @IBOutlet weak var connectionTimeLabelButton: UIButton!
    
    @IBOutlet weak var originalIPAddressLabel: UILabel!
    @IBOutlet weak var originalLocaleLabelButton: UIButton!

    @IBOutlet weak var disconnectedLabel: UILabel!
    @IBOutlet weak var connectedTimeView: UIView!
    @IBOutlet weak var newIPAddressLabel: UILabel!
    @IBOutlet weak var newLocalLabelButton: UIButton!
    
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
extension SettingsStatusViewController: StoreSubscriber {
    func newState(state: AppState) {
        let statusState = state.statusState
        self.originalIPAddressLabel.text = statusState.originalIPAddress ?? "---.---.---.---"
        self.newIPAddressLabel.text = statusState.newIPAddress ?? "---.---.---.---"
    }
}
