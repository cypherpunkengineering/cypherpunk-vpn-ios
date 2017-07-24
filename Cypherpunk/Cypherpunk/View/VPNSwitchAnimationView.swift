//
//  VPNSwitchAnimationView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/19/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import Cartography

class VPNSwitchAnimationView: UIView {
    let nonConnectedLineHeight: CGFloat = 6.0
    let lineWidth: CGFloat = 45.0
    let dotHeight: CGFloat = 6.0
    let ellipsisRadius: CGFloat = 20.0
    
    let vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 115, height: 60))
    let lineLayer = CAShapeLayer()
    let ovalLayer = CAShapeLayer()
    let leftLineLayer = CAShapeLayer()
    let rightLineLayer = CAShapeLayer()
    let chaserLayer = CAShapeLayer()
    let chaserGradientLayer = CAGradientLayer()
    
    var vpnSwitchDelegate: VPNSwitchDelegate? {
        didSet {
            self.vpnSwitch.delegate = self.vpnSwitchDelegate
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        self.addSubview(self.vpnSwitch)
        constrain(self, self.vpnSwitch) { parentView, childView in
            childView.height == self.vpnSwitch.frame.height
            childView.width == self.vpnSwitch.frame.width
            childView.centerX == parentView.centerX
            childView.centerY == parentView.centerY
        }
        
        setupLineLayers()
    }
    
    private func setupLineLayers() {
        let widthBetweenSwitchAndEdge = (self.frame.width - self.vpnSwitch.frame.width) / 2
        
        // left of the switch
        let leftLineFrame = CGRect(x: 0, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge, height: nonConnectedLineHeight)
        let leftLinePath = UIBezierPath(rect: leftLineFrame)
        self.leftLineLayer.path = leftLinePath.cgPath
        self.leftLineLayer.fillColor = UIColor(red: 0.0, green: 255.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.75).cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.frame = leftLineFrame
        self.leftLineLayer.mask = gradientLayer
        
        // right of the switch
        let rightLineFrame = CGRect(x: self.bounds.width - widthBetweenSwitchAndEdge, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge, height: nonConnectedLineHeight)
        let rightLinePath = UIBezierPath(rect: rightLineFrame)
        self.rightLineLayer.path = rightLinePath.cgPath
        self.rightLineLayer.fillColor = UIColor(red: 0.0, green: 255.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0).cgColor
        
        let rightLineGradientLayer = CAGradientLayer()
        rightLineGradientLayer.colors = [UIColor(white: 0.0, alpha: 0.75).cgColor, UIColor.clear.cgColor]
        rightLineGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightLineGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        rightLineGradientLayer.frame = rightLineFrame
        self.rightLineLayer.mask = rightLineGradientLayer
        self.layer.addSublayer(self.leftLineLayer)
        self.layer.addSublayer(self.rightLineLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupLineLayers()
    }
    
    func beginConnectAnimation() {
        let chaserYValue = self.bounds.height / 2 // - nonConnectedLineHeight / 2
        let originalChaserBounds = CGRect(x: 0, y: chaserYValue, width: lineWidth, height: nonConnectedLineHeight)
        
        self.chaserGradientLayer.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.2).cgColor, UIColor.white.cgColor, UIColor(white: 0.0, alpha: 0.2).cgColor, UIColor.clear.cgColor]
        self.chaserGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.chaserGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.chaserGradientLayer.locations = [0.1, 0.2, 0.5, 0.8, 0.9]
        self.chaserGradientLayer.frame = CGRect(x: 0, y: chaserYValue, width: lineWidth, height: nonConnectedLineHeight)

        self.layer.insertSublayer(self.chaserGradientLayer, below: self.vpnSwitch.layer)
        
        // move to min
        
        let leftLineAnimataion = CABasicAnimation(keyPath: "position")
        leftLineAnimataion.fromValue = [0, chaserYValue]
        leftLineAnimataion.toValue = [self.vpnSwitch.frame.minX - lineWidth, chaserYValue]
        leftLineAnimataion.beginTime = 0.0
        leftLineAnimataion.duration = 0.5
        
        // shrink to dot and move to left
        
        let dotBounds = CGRect(x: 0, y: chaserYValue, width: dotHeight, height: dotHeight)
        
        let shrinkDotAnimation = CABasicAnimation(keyPath: "bounds")
        shrinkDotAnimation.fromValue = originalChaserBounds
        shrinkDotAnimation.toValue = dotBounds
        shrinkDotAnimation.beginTime = leftLineAnimataion.beginTime + leftLineAnimataion.duration
        shrinkDotAnimation.duration = 0.1
        
        let dotMoveToLeftAnimation = CABasicAnimation(keyPath: "position")
        dotMoveToLeftAnimation.fromValue = [vpnSwitch.frame.minX - lineWidth, chaserYValue]
        dotMoveToLeftAnimation.toValue = [vpnSwitch.frame.minX, chaserYValue]
        dotMoveToLeftAnimation.beginTime = shrinkDotAnimation.beginTime
        dotMoveToLeftAnimation.duration = shrinkDotAnimation.duration
        
        // expand and move to min + radius
        
        let barMiddleBounds = CGRect(x: 0, y: vpnSwitch.frame.minY, width: 20, height: self.vpnSwitch.frame.height)
        let barExpandAnimation = CABasicAnimation(keyPath: "bounds")
        barExpandAnimation.fromValue = dotBounds
        barExpandAnimation.toValue = barMiddleBounds
        barExpandAnimation.beginTime = dotMoveToLeftAnimation.beginTime + dotMoveToLeftAnimation.duration
        barExpandAnimation.duration = 0.1
        
        
        let barLeftPositionAnimation = CABasicAnimation(keyPath: "position")
        barLeftPositionAnimation.fromValue = [self.vpnSwitch.frame.minX, chaserYValue]
        barLeftPositionAnimation.toValue = [self.vpnSwitch.frame.minX + ellipsisRadius, chaserYValue]
        barLeftPositionAnimation.beginTime = barExpandAnimation.beginTime
        barLeftPositionAnimation.duration = barExpandAnimation.duration
        
        // move from min + radius to max - radius
        
        let barMiddlePositionAnimation = CABasicAnimation(keyPath: "position")
        barMiddlePositionAnimation.fromValue = [self.vpnSwitch.frame.minX + ellipsisRadius, chaserYValue]
        barMiddlePositionAnimation.toValue = [self.vpnSwitch.frame.maxX - ellipsisRadius, chaserYValue]
        barMiddlePositionAnimation.beginTime = barExpandAnimation.beginTime + barExpandAnimation.duration
        barMiddlePositionAnimation.duration = 0.25
        
        let barMiddleKeepExpanded = CABasicAnimation(keyPath: "bounds")
        barMiddleKeepExpanded.fromValue = barMiddleBounds
        barMiddleKeepExpanded.toValue = barMiddleBounds
        barMiddleKeepExpanded.beginTime = barMiddlePositionAnimation.beginTime
        barMiddleKeepExpanded.duration = barMiddlePositionAnimation.duration
        
        
        // move max - radius to max, and shrink
        
        let barPositionRightAnimation = CABasicAnimation(keyPath: "position")
        barPositionRightAnimation.fromValue = [self.vpnSwitch.frame.maxX - ellipsisRadius, chaserYValue]
        barPositionRightAnimation.toValue = [self.vpnSwitch.frame.maxX - dotHeight, chaserYValue]
        barPositionRightAnimation.beginTime = barMiddlePositionAnimation.beginTime + barMiddlePositionAnimation.duration
        barPositionRightAnimation.duration = 0.1
        
        let barShrinkAnimation = CABasicAnimation(keyPath: "bounds")
        barShrinkAnimation.fromValue = barMiddleBounds
        barShrinkAnimation.toValue = dotBounds
        barShrinkAnimation.beginTime = barPositionRightAnimation.beginTime
        barShrinkAnimation.duration = barPositionRightAnimation.duration
        
        // expand dot to line

        let expandDotToLineAnimation = CABasicAnimation(keyPath: "bounds")
        expandDotToLineAnimation.fromValue = dotBounds
        expandDotToLineAnimation.toValue = originalChaserBounds
        expandDotToLineAnimation.beginTime = barPositionRightAnimation.beginTime + barPositionRightAnimation.duration
        expandDotToLineAnimation.duration = 0.1
        
        let keepDotToRightAnimation = CABasicAnimation(keyPath: "position")
        keepDotToRightAnimation.fromValue = [vpnSwitch.frame.maxX - dotHeight , chaserYValue]
        keepDotToRightAnimation.toValue = [self.vpnSwitch.frame.maxX, chaserYValue]
        keepDotToRightAnimation.beginTime = expandDotToLineAnimation.beginTime
        keepDotToRightAnimation.duration = expandDotToLineAnimation.duration
        
        // move to right
        
        let rightLineAnimation = CABasicAnimation(keyPath: "position")
        rightLineAnimation.fromValue = [self.vpnSwitch.frame.maxX, chaserYValue]
        rightLineAnimation.toValue = [self.bounds.width, chaserYValue]
        rightLineAnimation.beginTime = expandDotToLineAnimation.beginTime + expandDotToLineAnimation.duration
        rightLineAnimation.duration = 0.5
        
        let heartbeatAnimation = CAAnimationGroup()
        heartbeatAnimation.animations = [
            leftLineAnimataion,
            shrinkDotAnimation,
            dotMoveToLeftAnimation,
            barExpandAnimation,
            barLeftPositionAnimation,
            barMiddlePositionAnimation,
            barMiddleKeepExpanded,
            barShrinkAnimation,
            expandDotToLineAnimation,
            keepDotToRightAnimation,
            barPositionRightAnimation,
            rightLineAnimation
        ]
        heartbeatAnimation.duration = rightLineAnimation.beginTime + rightLineAnimation.duration
        heartbeatAnimation.repeatCount = .infinity
        heartbeatAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        self.chaserGradientLayer.add(heartbeatAnimation, forKey: "heartbeatAnimation")
    }
    
    func cancelConnectAnimation() {
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
    }
    
    func transitionToConnectedAnimation() {
        
    }
}
