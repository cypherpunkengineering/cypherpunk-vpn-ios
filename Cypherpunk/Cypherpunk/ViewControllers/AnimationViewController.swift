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
    
    let itemSize = CGSizeMake(14,22)
    
    let scrollDistancePerSec = 5.25
    
    var animationLayer: CALayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if animationLayer == nil {
            animationLayer = instanceAnimationLayer()
            self.view.layer.insertSublayer(animationLayer, atIndex: 0)
            startTimer()
        }
        //    startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var speed = 1.0
    func didChangeVPNStatus(notification: NSNotification) {
        guard let connection = notification.object as? NEVPNConnection else {
            return
        }
        
        let status = connection.status
        
        switch status {
        case .Connected:
            speed = 2.0
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if CGColorEqualToColor(textLayer.foregroundColor,UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor) == false {
                                let baseColor = UIColor(red: 175.0 / 255.0, green: 240.0 / 255.0, blue: 103.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.CGColor
                            } else {
                                if let string = textLayer.string as? String where string == "0" || string == "1" {
                                    textLayer.string = String(RandomCharacterGenerator.generate())
                                }
                            }
                        }
                    }
                }
            }
        case .Connecting:
            speed = 1.5
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if CGColorEqualToColor(textLayer.foregroundColor,UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor) == false {
                                let baseColor = UIColor(red: 255.0 / 255.0, green: 120.0 / 255.0, blue: 27.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.CGColor
                            }
                        }
                    }
                }
            }
        case .Disconnected:
            speed = 1.0
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if CGColorEqualToColor(textLayer.foregroundColor,UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor) == false {
                                let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue: 53.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.CGColor
                            }
                        }
                    }
                }
            }
        case .Disconnecting:
            speed = 1.5
            if animationLayer != nil && animationLayer.sublayers != nil {
                for row in animationLayer.sublayers! {
                    for textLayer in row.sublayers! {
                        if let textLayer = textLayer as? CATextLayer {
                            if CGColorEqualToColor(textLayer.foregroundColor,UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor) == false {
                                let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue: 53.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.5)
                                textLayer.foregroundColor = baseColor.CGColor
                            } else {
                                if let string = textLayer.string as? String where string != "0" && string != "1" {
                                    let number: Int = random() % 2
                                    textLayer.string = String(number)
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
    
    func instanceAnimationLayer() -> CALayer {
        
        let layer = CALayer()
        layer.frame = self.view.frame
        
        let horizontalItemsCount = Int(ceil(view.frame.width / (itemSize.width + 3.0)))
        let verticalItemsCount = Int(ceil(view.frame.height / itemSize.height)) + 4
        let font = UIFont(name: "Menlo-Regular", size: 21)
        print(horizontalItemsCount)
        let deviceNameColumn = horizontalItemsCount - 2
        let deviceName = SpecificDataProvider.deviceName().uppercaseString
        let deviceNameStartIndex = 5
        let deviceNameEndIndex = deviceNameStartIndex + deviceName.characters.count
        
        let carrierNameColumn = horizontalItemsCount - 5
        let carrierName = SpecificDataProvider.carrierName()?.uppercaseString
        let carrierNameStartIndex = 2
        let carrierNameEndIndex: Int
        if let carrierName = carrierName {
            carrierNameEndIndex = carrierNameStartIndex + carrierName.characters.count
        } else {
            carrierNameEndIndex = 0
        }
        
        for x in 0...horizontalItemsCount {
            let verticalLayer = CALayer()
            
            let size = CGSize(width: itemSize.width, height: CGFloat(verticalItemsCount) * itemSize.height)
            verticalLayer.frame = CGRect(origin: CGPoint(x: CGFloat(x) * itemSize.width + CGFloat(x) * 3.0 , y: 0), size: size)
            
            for y in 0...verticalItemsCount {
                let number: Int = random() % 2
                let layoutPoint = CGPoint(x: 0 , y: CGFloat(y) * itemSize.height)
                let frame = CGRect(origin: layoutPoint, size: itemSize)
                
                let textLayer = CATextLayer()
                
                if x == deviceNameColumn && deviceNameStartIndex <= y && y < deviceNameEndIndex {
                    let index = deviceName.startIndex.advancedBy(y - deviceNameStartIndex)
                    let text = deviceName[index]
                    textLayer.string = String(text)
                    textLayer.font = font
                    textLayer.fontSize = 21
                    let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue:53.0/255.0, alpha: 1.0)
                    textLayer.foregroundColor = baseColor.CGColor
                }else if let carrierName = carrierName where x == carrierNameColumn && carrierNameStartIndex <= y && y < carrierNameEndIndex {
                    print(y)
                    let index = carrierName.startIndex.advancedBy(y - carrierNameStartIndex)
                    let text = carrierName.characters[index]
                    textLayer.string = String(text)
                    textLayer.font = font
                    textLayer.fontSize = 21
                    let baseColor = UIColor(red: 241.0 / 255.0, green: 27.0 / 255.0, blue:53.0/255.0, alpha: 1.0)
                    textLayer.foregroundColor = baseColor.CGColor
                } else {
                    textLayer.string = String(number)
                    textLayer.font = font
                    textLayer.fontSize = 21
                    
                    let baseColor = UIColor.whiteColor()
                    textLayer.foregroundColor = baseColor.colorWithAlphaComponent(0.15).CGColor
                }
                
                textLayer.frame = frame
                
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.contentsScale = UIScreen.mainScreen().scale
                
                verticalLayer.addSublayer(textLayer)
            }
            layer.addSublayer(verticalLayer)
        }
        return layer
    }
    
    var beforeSec: NSTimeInterval = 0
    
    var timer: NSTimer!
    func update() {
        let now = NSDate().timeIntervalSince1970
        
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
        
        self.beforeSec = NSDate().timeIntervalSince1970
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: #selector(AnimationViewController.update), userInfo: nil, repeats: true)
    }
    
    func cancelTimer() {
    }
    
}
