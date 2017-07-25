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
        let widthBetweenSwitchAndEdge = (self.frame.width - self.vpnSwitch.frame.width) / 2
        
        let radius = self.bounds.height / 2
        let arcPointDelta: CGFloat = 18 // used to "pull" the arc point onto the switch to have the arc surround the switch
        
        let baseRect = CGRect(x: self.vpnSwitch.frame.minX - arcPointDelta, y: 0, width: self.vpnSwitch.bounds.width + 2 * arcPointDelta, height: self.bounds.height)
        let curvedShapePath = UIBezierPath(roundedRect: baseRect, cornerRadius: self.bounds.height / 2)
        curvedShapePath.usesEvenOddFillRule = true
        curvedShapePath.close()
        
        let leftArcCenterPoint = CGPoint(x: baseRect.minX + baseRect.height / 2, y: self.bounds.height / 2)
        let rightArcCenterPoint = CGPoint(x: baseRect.maxX - baseRect.height / 2, y: self.bounds.height / 2)
        
        let innerPath = UIBezierPath()
        innerPath.move(to: CGPoint(x: rightArcCenterPoint.x, y: 0))
        innerPath.addCurve(to: CGPoint(x: rightArcCenterPoint.x, y: self.bounds.height), controlPoint1: CGPoint(x: rightArcCenterPoint.x + radius, y: 10), controlPoint2: CGPoint(x: rightArcCenterPoint.x + radius, y: self.bounds.height - 10))
        innerPath.addLine(to: CGPoint(x: leftArcCenterPoint.x, y: self.bounds.height))
        innerPath.addCurve(to: CGPoint(x: leftArcCenterPoint.x, y: 0), controlPoint1: CGPoint(x: leftArcCenterPoint.x - radius, y: self.bounds.height - 10), controlPoint2: CGPoint(x: leftArcCenterPoint.x - radius, y: 10))
        innerPath.addLine(to: CGPoint(x: rightArcCenterPoint.x, y: 0))
        innerPath.close()
        
        curvedShapePath.append(innerPath)
        let maskLayer = CAShapeLayer()
        maskLayer.path = curvedShapePath.cgPath
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.switchGlowShapeLayer.mask = maskLayer
        
        self.switchGlowShapeLayer.fillColor = UIColor.disconnectedLineColor.cgColor
        self.switchGlowShapeLayer.path = curvedShapePath.cgPath
        
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
        // surround the switch
        let vpnSwitchFrame = self.vpnSwitch.frame
        let vpnSwitchHeight = vpnSwitchFrame.height
        let vpnSwitchWidth = vpnSwitchFrame.width

        let baseRect = CGRect(x: vpnSwitchFrame.minX - 10, y: vpnSwitchFrame.minY - 10, width: vpnSwitchFrame.width + 20, height: vpnSwitchFrame.height + 20)
        let path = UIBezierPath(roundedRect: baseRect, cornerRadius: self.bounds.height / 2)
        path.usesEvenOddFillRule = true
        
        let innerPath = UIBezierPath(roundedRect: CGRect(x: vpnSwitchFrame.minX, y: vpnSwitchFrame.minY, width: vpnSwitchWidth, height: vpnSwitchHeight), cornerRadius: vpnSwitchHeight / 2)
        path.append(innerPath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        self.switchGlowShapeLayer.mask = maskLayer
        
        
        let switchGlowPathAnimation = CABasicAnimation(keyPath: "path")
        switchGlowPathAnimation.fromValue = self.switchGlowShapeLayer.path
        switchGlowPathAnimation.toValue = path
        switchGlowPathAnimation.duration = 0.5
        
        let switchGlowMaskAnimation = CABasicAnimation(keyPath: "mask")
        switchGlowMaskAnimation.fromValue = self.switchGlowShapeLayer.mask
        switchGlowMaskAnimation.toValue = maskLayer
        switchGlowMaskAnimation.duration = 0.5
        switchGlowMaskAnimation.isAdditive = true
        
        let switchGlowFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
        switchGlowFillColorAnimation.fromValue = self.switchGlowShapeLayer.fillColor
        switchGlowFillColorAnimation.toValue = UIColor.connectingLineColor.cgColor
        switchGlowFillColorAnimation.duration = 0.5
        
        let switchGlowAnimationGroup = CAAnimationGroup()
        switchGlowAnimationGroup.animations = [
            switchGlowPathAnimation,
            switchGlowMaskAnimation,
            switchGlowFillColorAnimation
        ]
        
        self.switchGlowShapeLayer.add(switchGlowAnimationGroup, forKey: "switchGlowAnimation")
        
        self.switchGlowShapeLayer.path = path.cgPath
        self.switchGlowShapeLayer.fillColor = UIColor.connectingLineColor.cgColor
        self.switchGlowShapeLayer.fillRule = kCAFillRuleEvenOdd
        
        let chaserYValue = self.bounds.height / 2 // - nonConnectedLineHeight / 2
        let originalChaserBounds = CGRect(x: 0, y: chaserYValue, width: lineWidth, height: nonConnectedLineHeight)
        
        self.leftLineGradientLayer.colors = self.connectingGradientColors
        self.rightLineGradientLayer.colors = self.connectingGradientColors
        
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
