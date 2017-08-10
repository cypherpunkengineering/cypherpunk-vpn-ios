//
//  SlidingNavigationViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

let kOpenOrCloseConfigurationNotification = Notification.Name(rawValue: "kOpenOrCloseConfigurationNotification")
let kOpenOrCloseAccountNotification = Notification.Name(rawValue: "kOpenOrCloseAccountNotification")
let kResetCenterViewNotification = Notification.Name(rawValue: "kResetCenterViewNotification")

class SlidingNavigationViewController: UIViewController {

    enum SlideState {
        case left
        case center
        case right
    }
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var configContainerView: UIView!
    @IBOutlet weak var accountContainerView: UIView!
    @IBOutlet weak var fakeLaunchView: UIView!
    @IBOutlet var resetTapRecognizer: UITapGestureRecognizer!
    
    private var centerState = SlideState.center {
        didSet {
            if centerState == .center {
                self.topContainerView.removeGestureRecognizer(resetTapRecognizer)
            } else {
                self.topContainerView.addGestureRecognizer(resetTapRecognizer)
            }
        }
    }
    var slideWidth: CGFloat = 276
    var sidePanelOffset: CGFloat = -138 // half the width of the side panels
    
    static let animationTime: Double = 0.3

    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var configTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountLeadingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        resetTapRecognizer.numberOfTapsRequired = 1
        resetTapRecognizer.numberOfTouchesRequired = 1
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseConfiguration), name: kOpenOrCloseConfigurationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseAccount), name: kOpenOrCloseAccountNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetCenterView), name: kResetCenterViewNotification, object: nil)
        centerState = .center
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openOrCloseConfiguration() {
        if self.centerConstraint.constant == 0.0 {
            self.centerConstraint.constant = -slideWidth
            self.configTrailingConstraint.constant = 0.0
            self.view.setNeedsUpdateConstraints()
            self.centerState = .left
            self.view.sendSubview(toBack: self.accountContainerView)
            UIView.animate(withDuration: SlidingNavigationViewController.animationTime, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)

        } else {
            self.centerConstraint.constant = 0.0
            self.configTrailingConstraint.constant = sidePanelOffset
            self.view.setNeedsUpdateConstraints()
            self.centerState = .center
            UIView.animate(withDuration: SlidingNavigationViewController.animationTime, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)

        }
    }
    func openOrCloseAccount() {
        if self.centerConstraint.constant == 0.0 {
            self.centerConstraint.constant = slideWidth
            self.accountLeadingConstraint.constant = 0.0
            self.centerState = .right
            self.view.setNeedsUpdateConstraints()
            self.view.sendSubview(toBack: self.configContainerView)
            UIView.animate(withDuration: SlidingNavigationViewController.animationTime, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
            
        } else {
            self.centerConstraint.constant = 0.0
            self.accountLeadingConstraint.constant = sidePanelOffset
            self.view.setNeedsUpdateConstraints()
            self.centerState = .center
            UIView.animate(withDuration: SlidingNavigationViewController.animationTime, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    @IBAction func recognizeResetTapAction(recognizer: UITapGestureRecognizer) {
        if centerState != .center {
            resetCenterView()
        }
    }
    
    func resetCenterView() {
        self.centerState = .center
        self.centerConstraint.constant = 0.0
        self.accountLeadingConstraint.constant = sidePanelOffset
        self.configTrailingConstraint.constant = sidePanelOffset
        self.view.setNeedsUpdateConstraints()
        self.centerState = .center
        UIView.animate(withDuration: SlidingNavigationViewController.animationTime, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private var beganPositionX: CGFloat!
    private var beganTranslatedPositionX: CGFloat!

    @IBAction func reconizePanGestureAction(_ recognizer: UIPanGestureRecognizer) {
        let translated = recognizer.translation(in: recognizer.view!)
        
        switch (recognizer.state){
        case .began:
            beganPositionX = centerConstraint.constant
            beganTranslatedPositionX = translated.x
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: recognizer.view!)
            let finalX = translated.x + (0.35 * velocity.x);
            let moved = beganTranslatedPositionX + finalX
            let lastConstant: CGFloat
            lastConstant = min(max(-slideWidth, beganPositionX + moved), slideWidth)
            
            
            if lastConstant <= -slideWidth * 0.5 {
                if self.centerState == .right {
                    self.centerConstraint.constant = 0
                    self.centerState = .center
                    self.accountLeadingConstraint.constant = sidePanelOffset
                    self.configTrailingConstraint.constant = sidePanelOffset
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
                else {
                    self.centerConstraint.constant = -slideWidth
                    self.centerState = .left
                    self.configTrailingConstraint.constant = 0
                    self.view.sendSubview(toBack: self.accountContainerView)
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
            }
            else if lastConstant >= slideWidth * 0.5 {
                if self.centerState == .left {
                    self.centerConstraint.constant = 0
                    self.centerState = .center
                    self.accountLeadingConstraint.constant = sidePanelOffset
                    self.configTrailingConstraint.constant = sidePanelOffset
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
                else {
                    self.centerConstraint.constant = slideWidth
                    self.centerState = .right
                    self.accountLeadingConstraint.constant = 0
                    self.view.sendSubview(toBack: self.configContainerView)
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)                    
                }
            }
            else  {
                self.centerConstraint.constant = 0.0
                self.centerState = .center
                self.accountLeadingConstraint.constant = sidePanelOffset
                self.configTrailingConstraint.constant = sidePanelOffset
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
            
        default:
            let moved = beganTranslatedPositionX + translated.x
            centerConstraint.constant = min(max(-slideWidth, beganPositionX + moved), slideWidth)
            
            if centerConstraint.constant < 0 {
                self.view.sendSubview(toBack: self.accountContainerView)
            }
            else {
                self.view.sendSubview(toBack: self.configContainerView)
            }

            // <-- negative move
            // --> positive move
            if moved > 0 {
                // moving to the right
                if beganPositionX + (moved / 2) < slideWidth {
                    accountLeadingConstraint.constant = min(sidePanelOffset + moved / 2, 0)
                    configTrailingConstraint.constant = max(-(moved / 2), sidePanelOffset)
                }
            }
            else {
                // moving to the left
                if abs(beganPositionX + moved / 2) < slideWidth {
                    accountLeadingConstraint.constant = max((moved / 2), sidePanelOffset)
                    configTrailingConstraint.constant = min(sidePanelOffset - moved / 2, 0)
                }
            }
        }
    
    }

}
