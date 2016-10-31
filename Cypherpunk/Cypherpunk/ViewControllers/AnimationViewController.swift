//
//  AnimationViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import CoreGraphics
import NetworkExtension

class AnimationViewController: UIViewController {
    
    let itemSize = CGSize(width: 14,height: 22)
    
    let scrollDistancePerSec = 6.0
    
    var animationLayer: CALayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(didChangeVPNStatus),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        center.addObserver(
            self,
            selector: #selector(startTimer),
            name: Notification.Name.UIApplicationWillEnterForeground,
            object: nil)
        center.addObserver(
            self,
            selector: #selector(cancelTimer),
            name: Notification.Name.UIApplicationWillResignActive,
            object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if animationLayer != nil {
            cancelTimer()
            animationLayer.removeFromSuperlayer()
            animationLayer = nil
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if animationLayer == nil {
            animationLayer = instanceAnimationLayer()
            self.view.layer.insertSublayer(animationLayer, at: 0)
            startTimer()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var speed = 1.0
    func didChangeVPNStatus(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
     
        self.updateAnimationState(status: status)
    }
    
    func updateAnimationState(status: NEVPNStatus) {
        switch status {
        case .connected:
            speed = 1.0
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if textLayer.foregroundColor != UIColor.white.withAlphaComponent(0.15).cgColor {
                                let baseColor = UIColor(red: 175.0 / 255.0, green: 240.0 / 255.0, blue: 103.0/255.0, alpha: 1.0).withAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.cgColor
                            } else {
                                if let string = textLayer.string as? String , string == "0" || string == "1" {
                                    textLayer.string = String(RandomCharacterGenerator.generate())
                                }
                            }
                        }
                    }
                }
            }
        case .connecting:
            speed = 1.0
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if textLayer.foregroundColor != UIColor.white.withAlphaComponent(0.15).cgColor {
                                let baseColor = UIColor(red: 255.0 / 255.0, green: 120.0 / 255.0, blue: 27.0/255.0, alpha: 1.0).withAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.cgColor
                            }
                        }
                    }
                }
            }
        case .disconnected:
            speed = 1.0
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if textLayer.foregroundColor != UIColor.white.withAlphaComponent(0.15).cgColor {
                                let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue: 53.0/255.0, alpha: 1.0).withAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.cgColor
                            } else {
                                if let string = textLayer.string as? String , string != "0" && string != "1" {
                                    let number =  arc4random_uniform(2)
                                    textLayer.string = String(UInt(number))
                                }
                                
                            }
                        }
                    }
                }
            }
        case .disconnecting:
            speed = 1.5
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if textLayer.foregroundColor != UIColor.white.withAlphaComponent(0.15).cgColor {
                                let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue: 53.0/255.0, alpha: 1.0).withAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.cgColor
                            } else {
                                if let string = textLayer.string as? String , string != "0" && string != "1" {
                                    let number =  arc4random_uniform(2)
                                    textLayer.string = String(UInt(number))
                                }
                                
                            }
                        }
                    }
                }
            }
        default:
            speed = 0
        }
    }
    
    private let normalFontSize: CGFloat = 24.0
    private let multibyteCharacterFontSize: CGFloat = 18.0
    
    func instanceAnimationLayer() -> CALayer {
        
        let layer = CALayer()
        layer.frame = self.view.frame
        
        let horizontalItemsCount = Int(ceil(view.frame.width / (itemSize.width + 3.0)))
        let verticalItemsCount = Int(ceil(view.frame.height / itemSize.height)) + 4
        let font = R.font.inconsolataRegular(size: normalFontSize)
        
        for x in 0...horizontalItemsCount {
            let verticalLayer = CALayer()
            
            let size = CGSize(width: itemSize.width, height: CGFloat(verticalItemsCount) * itemSize.height)
            verticalLayer.frame = CGRect(origin: CGPoint(x: CGFloat(x) * itemSize.width + CGFloat(x) * 3.0 , y: 0), size: size)
            
            for y in 0...verticalItemsCount {
                
                let number = Int(arc4random_uniform(2))
                let layoutPoint = CGPoint(x: 0 , y: CGFloat(y) * itemSize.height)
                let frame = CGRect(origin: layoutPoint, size: itemSize)
                let textLayer = CATextLayer()
                textLayer.frame = frame
                textLayer.string = String(number)
                textLayer.font = font
                textLayer.fontSize = normalFontSize
                
                let baseColor = UIColor.white
                textLayer.foregroundColor = baseColor.withAlphaComponent(0.15).cgColor
                
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.contentsScale = UIScreen.main.scale
                
                verticalLayer.addSublayer(textLayer)
            }
            layer.addSublayer(verticalLayer)
        }
        return layer
    }
    
    var beforeSec: TimeInterval = 0
    
    var timer: Timer!
    func update() {
        let now = Date().timeIntervalSince1970
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var index = 0
        for sub in self.animationLayer.sublayers! {
            for textLayer in sub.sublayers! {
                switch index % 2 {
                case 0:
                    var yPosition = textLayer.position.y + CGFloat(scrollDistancePerSec * Double(now - self.beforeSec) * speed)
                    if yPosition >= sub.frame.size.height {
                        yPosition = yPosition - (sub.frame.size.height + itemSize.height)
                    }
                    textLayer.position = CGPoint(x: textLayer.position.x, y: yPosition)
                    
                case 1:
                    var yPosition = textLayer.position.y - CGFloat(scrollDistancePerSec * Double(now - self.beforeSec) * speed)
                    if yPosition <= -itemSize.height {
                        yPosition = yPosition + sub.frame.size.height + itemSize.height
                    }
                    textLayer.position = CGPoint(x: textLayer.position.x, y: yPosition)
                default:
                    fatalError()
                }
            }
            index = index + 1
        }
        CATransaction.commit()
        self.beforeSec = now
    }
    
    func startTimer() {
        if timer == nil {
            self.beforeSec = Date().timeIntervalSince1970
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(AnimationViewController.update), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
    }
    
    func cancelTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
}
