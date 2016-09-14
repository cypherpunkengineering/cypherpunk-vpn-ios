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
        case .Connecting:
            speed = 1.5
        case .Disconnected:
            speed = 1.0
        case .Disconnecting:
            speed = 1.5
        default:
            speed = 0
        }
        
    }

    func instanceAnimationLayer() -> CALayer {
        
        let layer = CALayer()
        layer.frame = self.view.frame
        
        let horizontalItemsCount = Int(ceil(view.frame.width / itemSize.width))
        let verticalItemsCount = Int(ceil(view.frame.height / itemSize.height)) + 4
        let font = UIFont(name: "Menlo-Regular", size: 21)
        
        for x in 0...horizontalItemsCount {
            let verticalLayer = CALayer()
            
            let size = CGSize(width: itemSize.width, height: CGFloat(verticalItemsCount) * itemSize.height)
            verticalLayer.frame = CGRect(origin: CGPoint(x: CGFloat(x) * itemSize.width + CGFloat(x) * 3.0 , y: 0), size: size)
            
            for y in 0...verticalItemsCount {
                let number: Int = random() % 2
                let layoutPoint = CGPoint(x: 0 , y: CGFloat(y) * itemSize.height)
                let frame = CGRect(origin: layoutPoint, size: itemSize)
                
                let textLayer = CATextLayer()
                textLayer.string = String(number)
                textLayer.font = font
                textLayer.fontSize = 21
                
                let baseColor = UIColor.whiteColor()
                
                textLayer.foregroundColor = baseColor.colorWithAlphaComponent(0.15).CGColor
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
                    var yPosition = textLayer.position.y + CGFloat(10.5 * Double(now - self.beforeSec) * speed)
                    if yPosition >= sub.frame.size.height {
                        yPosition = yPosition - (sub.frame.size.height + itemSize.height)
                    }
                    textLayer.position = CGPoint(x: textLayer.position.x, y: yPosition)

                case 1:
                    var yPosition = textLayer.position.y - CGFloat(10.5 * Double(now - self.beforeSec) * speed)
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
