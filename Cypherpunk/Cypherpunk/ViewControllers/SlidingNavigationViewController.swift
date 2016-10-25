//
//  SlidingNavigationViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

let kOpenOrCloseConfigurationNotification = Notification.Name(rawValue: "kOpenOrCloseConfigurationNotification")

class SlidingNavigationViewController: UIViewController {

    enum SlideState {
        case left
        case center
        case right
    }
    
    private let state = SlideState.center
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(openOrCloseConfiguration), name: kOpenOrCloseConfigurationNotification, object: nil)
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
            let lastConstant = min(max(-274, beganPositionX + moved), 0)
            
            if lastConstant <= 0 && lastConstant > -274.0 * 0.5 {
                self.centerConstraint.constant = 0.0
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            } else if lastConstant <= -274.0 * 0.5 {
                self.centerConstraint.constant = -276
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
//            } else if lastConstant >= 0 && lastConstant < 274.0 * 0.5 {
//                self.centerConstraint.constant = 0.0
//                self.view.setNeedsUpdateConstraints()
//                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//                    self.view.layoutIfNeeded()
//                    }, completion: nil)
//            } else if lastConstant >= -274.0 * 0.5 {
//                self.centerConstraint.constant = 276
//                self.view.setNeedsUpdateConstraints()
//                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//                    self.view.layoutIfNeeded()
//                    }, completion: nil)
            }
            
        default:
            let moved = beganTranslatedPositionX + translated.x
            centerConstraint.constant = min(max(-274, beganPositionX + moved), 0)
        }
        
    }

}
