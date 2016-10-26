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

class SlidingNavigationViewController: UIViewController {

    enum SlideState {
        case left
        case center
        case right
    }
    
    private var centerState = SlideState.center
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseConfiguration), name: kOpenOrCloseConfigurationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseAccount), name: kOpenOrCloseAccountNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openOrCloseConfiguration() {
        if self.centerConstraint.constant == 0.0 {
            self.centerConstraint.constant = -276
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)

        } else {
            self.centerConstraint.constant = 0.0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)

        }
    }
    func openOrCloseAccount() {
        if self.centerConstraint.constant == 0.0 {
            self.centerConstraint.constant = 276
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
            
        } else {
            self.centerConstraint.constant = 0.0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
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
            if UI_USER_INTERFACE_IDIOM() == .pad {
                lastConstant = min(max(-274, beganPositionX + moved), 0)
            } else {
                lastConstant = min(max(-274, beganPositionX + moved), 274)
            }
            
            if lastConstant <= -274.0 * 0.5 {
                if self.centerState == .right {
                    self.centerConstraint.constant = 0
                    self.centerState = .center
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                } else {
                    self.centerConstraint.constant = -276
                    self.centerState = .left
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
            } else if lastConstant >= 274.0 * 0.5 {
                if self.centerState == .left {
                    self.centerConstraint.constant = 0
                    self.centerState = .center
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)
                } else {
                    self.centerConstraint.constant = 276
                    self.centerState = .right
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: nil)                    
                }
            } else  {
                self.centerConstraint.constant = 0.0
                self.centerState = .center
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
            
        default:
            let moved = beganTranslatedPositionX + translated.x
            if UI_USER_INTERFACE_IDIOM() == .pad {
                centerConstraint.constant = min(max(-274, beganPositionX + moved), 0)
            } else if UI_USER_INTERFACE_IDIOM() == .phone {
                centerConstraint.constant = min(max(-274, beganPositionX + moved), 274)
            }
        }
        
    }

}
