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
    let nonConnectedLineHeight: CGFloat = 5.0
    let lineWidth: CGFloat = 45.0
    let dotHeight: CGFloat = 5.0
    let ellipsisRadius: CGFloat = 20.0
    
    let vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 115, height: 60))
    let lineLayer = CAShapeLayer()
    let ovalLayer = CAShapeLayer()
    let leftLineGradientLayer = CAGradientLayer()
    let rightLineGradientLayer = CAGradientLayer()
    let chaserGradientLayer = CAGradientLayer()
    let switchGlowShapeLayer = CAShapeLayer()
    
    let gradientColors = [UIColor.disconnectedLineColor.cgColor, UIColor.disconnectedLineColor.withAlphaComponent(0.1).cgColor] as [Any]
    
    let connectingGradientColors = [UIColor.connectingLineColor.cgColor, UIColor.connectingLineColor.withAlphaComponent(0.1).cgColor] as [Any]

    
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
        let bezierPath = UIBezierPath()
        bezierPath.usesEvenOddFillRule = true
        
        let outerShapeDelta: CGFloat = 18
        
        let baseRect = CGRect(x: self.vpnSwitch.frame.minX - outerShapeDelta, y: 0, width: self.vpnSwitch.bounds.width + 2 * outerShapeDelta, height: self.bounds.height)
        let curvedShapePath = UIBezierPath(roundedRect: baseRect, cornerRadius: self.bounds.height / 2)
        curvedShapePath.usesEvenOddFillRule = true
        curvedShapePath.close()
        
        bezierPath.append(curvedShapePath)
        
        let innerPath = UIBezierPath(roundedRect: CGRect(x: self.vpnSwitch.frame.minX - 10, y: 0, width: self.vpnSwitch.bounds.width + 2 * 10, height: self.bounds.height), cornerRadius: self.bounds.height / 2 - 5)
        
        bezierPath.append(innerPath)
        
        self.switchGlowShapeLayer.path = bezierPath.cgPath
        self.switchGlowShapeLayer.fillColor = UIColor.disconnectedLineColor.cgColor
        self.switchGlowShapeLayer.fillRule = kCAFillRuleEvenOdd
        
        let widthBetweenSwitchAndEdge = (self.frame.width - self.vpnSwitch.frame.width) / 2
        
        // left of the switch
        let leftLineFrame = CGRect(x: 0, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight)
        self.leftLineGradientLayer.colors = self.gradientColors
        self.leftLineGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        self.leftLineGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        self.leftLineGradientLayer.frame = leftLineFrame
        
        // right of the switch
        let rightLineFrame = CGRect(x: self.bounds.width - widthBetweenSwitchAndEdge + 10, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight)
        self.rightLineGradientLayer.colors = self.gradientColors
        self.rightLineGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.rightLineGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.rightLineGradientLayer.frame = rightLineFrame
        
        self.layer.addSublayer(self.leftLineGradientLayer)
        self.layer.addSublayer(self.rightLineGradientLayer)
        self.layer.addSublayer(self.switchGlowShapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupLineLayers()
    }
    
    func beginConnectAnimation() {
        transformShapeAroundSwitch()
        
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
    
    private func transformShapeAroundSwitch() {
        // surround the switch
        let vpnSwitchFrame = self.vpnSwitch.frame
        let vpnSwitchHeight = vpnSwitchFrame.height
        let vpnSwitchWidth = vpnSwitchFrame.width
        
        let bezierPath = UIBezierPath()
        bezierPath.usesEvenOddFillRule = true
        
        let outerShapeDelta: CGFloat = 10
        
        let curvedShapePath = UIBezierPath(roundedRect: CGRect(x: vpnSwitchFrame.minX - outerShapeDelta, y: vpnSwitchFrame.minY - outerShapeDelta, width: vpnSwitchWidth + 2 * outerShapeDelta, height: vpnSwitchHeight + 2 * outerShapeDelta), cornerRadius: (vpnSwitchHeight + 2 * outerShapeDelta) / 2)
        curvedShapePath.usesEvenOddFillRule = true
        curvedShapePath.close()
        
        bezierPath.append(curvedShapePath)
        
        let innerPath = UIBezierPath(roundedRect: CGRect(x: vpnSwitchFrame.minX, y: vpnSwitchFrame.minY, width: vpnSwitchWidth, height: vpnSwitchHeight), cornerRadius: vpnSwitchHeight / 2)
        
        bezierPath.append(innerPath)
        
        let switchGlowPathAnimation = CABasicAnimation(keyPath: "path")
        switchGlowPathAnimation.fromValue = self.switchGlowShapeLayer.path
        switchGlowPathAnimation.toValue = bezierPath.cgPath
        switchGlowPathAnimation.duration = 0.3
        
        let switchGlowFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
        switchGlowFillColorAnimation.fromValue = self.switchGlowShapeLayer.fillColor
        switchGlowFillColorAnimation.toValue = UIColor.connectingLineColor.cgColor
        switchGlowFillColorAnimation.duration = 0.1
        
        let switchGlowAnimationGroup = CAAnimationGroup()
        switchGlowAnimationGroup.animations = [
            switchGlowPathAnimation,
            switchGlowFillColorAnimation
        ]
        
        self.switchGlowShapeLayer.add(switchGlowAnimationGroup, forKey: "switchGlowAnimation")
        
        self.switchGlowShapeLayer.path = bezierPath.cgPath
        self.switchGlowShapeLayer.fillColor = UIColor.connectingLineColor.cgColor
    }
    
    func cancelConnectAnimation() {
        self.leftLineGradientLayer.colors = self.gradientColors
        self.rightLineGradientLayer.colors = self.gradientColors
        
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
        
        self.setupLineLayers()
    }
    
    func transitionToConnectedAnimation() {
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
        
        let originalBounds = self.leftLineGradientLayer.bounds
        let newBounds = CGRect(x: originalBounds.minX, y: self.bounds.height / 2 - (self.vpnSwitch.bounds.height - 10) / 2, width: originalBounds.width, height: self.vpnSwitch.bounds.height - 10)

        let leftLineHeightAnimation = CABasicAnimation(keyPath: "bounds")
        leftLineHeightAnimation.fromValue = originalBounds
        leftLineHeightAnimation.toValue = newBounds
        
        self.leftLineGradientLayer.add(leftLineHeightAnimation, forKey: "heightChange")
        
        self.leftLineGradientLayer.bounds = newBounds
    }
}
