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
    let connectedLineHeight: CGFloat = 25.0
    let lineWidth: CGFloat = 45.0
    let dotHeight: CGFloat = 5.0
    let ellipsisRadius: CGFloat = 20.0
    let outerShapeDelta: CGFloat = 18.0
    let surroundShapeDelta: CGFloat = 10.0
    
    let vpnSwitch = VPNSwitch(frame: CGRect(x: 0, y: 0, width: 115, height: 60))
    let lineLayer = CAShapeLayer()
    let ovalLayer = CAShapeLayer()
    let leftLineGradientLayer = CAShapeLayer()
    let rightLineGradientLayer = CAShapeLayer()
    let leftLineGradientMask = CAGradientLayer()
    let rightLineGradientMask = CAGradientLayer()
    
    let chaserGradientLayer = CAGradientLayer()
    let switchGlowShapeLayer = CAShapeLayer()
    
    var originalCurvedPath: UIBezierPath?
    
    let disconnectGradientColors = [UIColor.disconnectedLineColor.cgColor, UIColor.disconnectedLineColor.withAlphaComponent(0.1).cgColor] as [Any]
    
    let connectGradientColors = [UIColor.connectingLineColor.cgColor, UIColor.connectingLineColor.withAlphaComponent(0.1).cgColor] as [Any]

    
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
        
        self.originalCurvedPath = bezierPath
        
        let widthBetweenSwitchAndEdge = (self.frame.width - self.vpnSwitch.frame.width) / 2
        
        leftLineGradientLayer.frame = CGRect(x: 0, y: 0, width: widthBetweenSwitchAndEdge - 10, height: self.bounds.height)
        
        rightLineGradientLayer.frame = CGRect(x: self.bounds.width - widthBetweenSwitchAndEdge + 10, y: 0, width: widthBetweenSwitchAndEdge - 10, height: self.bounds.height)

        
        // left of the switch
        let leftLinePath = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight))
        
        leftLineGradientMask.colors = connectGradientColors
        leftLineGradientMask.startPoint = CGPoint(x: 1.0, y: 0.5)
        leftLineGradientMask.endPoint = CGPoint(x: 0.0, y: 0.5)
        leftLineGradientMask.frame = leftLineGradientLayer.frame
        leftLineGradientLayer.mask = leftLineGradientMask
        
        leftLineGradientLayer.fillColor = UIColor.disconnectedLineColor.cgColor
        leftLineGradientLayer.path = leftLinePath.cgPath
        
        // right of the switch
        let rightLinePath = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight))
        
        rightLineGradientMask.colors = connectGradientColors
        rightLineGradientMask.startPoint = CGPoint(x: 0.0, y: 0.5)
        rightLineGradientMask.endPoint = CGPoint(x: 1.0, y: 0.5)
        rightLineGradientMask.frame = CGRect(x: 0, y: 0, width: widthBetweenSwitchAndEdge - 10, height: self.bounds.height)
        rightLineGradientLayer.mask = rightLineGradientMask
        
        rightLineGradientLayer.fillColor = UIColor.disconnectedLineColor.cgColor
        rightLineGradientLayer.path = rightLinePath.cgPath
        
        self.layer.addSublayer(leftLineGradientLayer)
        self.layer.addSublayer(rightLineGradientLayer)
        self.layer.addSublayer(switchGlowShapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupLineLayers()
    }
    
    func beginConnectAnimation() {
        transformShapeAroundSwitch()

        self.leftLineGradientLayer.fillColor = UIColor.connectingLineColor.cgColor
        self.rightLineGradientLayer.fillColor = UIColor.connectingLineColor.cgColor
        
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
    
    private func transformShapeAroundSwitch() {
        // surround the switch
        let vpnSwitchFrame = self.vpnSwitch.frame
        let vpnSwitchHeight = vpnSwitchFrame.height
        let vpnSwitchWidth = vpnSwitchFrame.width
        
        let bezierPath = UIBezierPath()
        bezierPath.usesEvenOddFillRule = true
        
        let curvedShapePath = UIBezierPath(roundedRect: CGRect(x: vpnSwitchFrame.minX - surroundShapeDelta, y: vpnSwitchFrame.minY - surroundShapeDelta, width: vpnSwitchWidth + 2 * surroundShapeDelta, height: vpnSwitchHeight + 2 * surroundShapeDelta), cornerRadius: (vpnSwitchHeight + 2 * surroundShapeDelta) / 2)
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
        animateLine(connect: false)
        
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
        
        let switchGlowPathAnimation = CABasicAnimation(keyPath: "path")
        switchGlowPathAnimation.fromValue = self.switchGlowShapeLayer.path
        switchGlowPathAnimation.toValue = self.originalCurvedPath?.cgPath
        switchGlowPathAnimation.duration = 0.3
        self.switchGlowShapeLayer.add(switchGlowPathAnimation, forKey: "path")
        
        let switchGlowFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
        switchGlowFillColorAnimation.fromValue = self.switchGlowShapeLayer.fillColor
        switchGlowFillColorAnimation.toValue = UIColor.disconnectedLineColor.cgColor
        switchGlowFillColorAnimation.duration = 0.1
        
        let switchGlowAnimationGroup = CAAnimationGroup()
        switchGlowAnimationGroup.animations = [
            switchGlowPathAnimation,
            switchGlowFillColorAnimation
        ]
        
        self.switchGlowShapeLayer.add(switchGlowAnimationGroup, forKey: "switchGlowAnimation")
        
        self.switchGlowShapeLayer.path = self.originalCurvedPath?.cgPath
        self.switchGlowShapeLayer.fillColor = UIColor.disconnectedLineColor.cgColor
    }
    
    func transitionToConnectedAnimation() {
        transformShapeAroundSwitch()
        animateLine(connect: true)
        
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
    }
    
    private func animateLine(connect: Bool) {
        
        let leftOriginalBounds = self.leftLineGradientLayer.bounds
        let rightOriginalBounds = self.rightLineGradientLayer.bounds
        var leftNewBounds: CGRect
        var rightNewBounds: CGRect
        
        
        if connect {
            let vpnSwitchFrame = vpnSwitch.frame
            let vpnSwitchHeight = vpnSwitchFrame.height
            let vpnSwitchWidth = vpnSwitchFrame.width
            
            let outerShapeHeight: CGFloat = vpnSwitchHeight + 2 * surroundShapeDelta
            let outerShapeWidth: CGFloat = vpnSwitchWidth + 2 * surroundShapeDelta
            let outerShapeMinX = self.bounds.midX - outerShapeWidth / 2
            
            // left line
            let leftArcCenter = CGPoint(x: outerShapeMinX + outerShapeHeight / 2, y: self.bounds.midY)
            let arcRadius = outerShapeHeight / 2
            
            let leftBezier = UIBezierPath(arcCenter: leftArcCenter, radius: arcRadius, startAngle: 5 * CGFloat.pi / 6, endAngle: 7 * CGFloat.pi / 6, clockwise: true)
            leftBezier.usesEvenOddFillRule = true
            
            let arcMinY = leftBezier.currentPoint.y
            
            leftBezier.addLine(to: CGPoint(x: 0, y: arcMinY))
            
            leftBezier.addLine(to: CGPoint(x: 0, y: self.bounds.height - arcMinY))
            
            let leftLineGradientMaskNew = CAGradientLayer()
            leftLineGradientMaskNew.colors = connectGradientColors
            leftLineGradientMaskNew.startPoint = CGPoint(x: 1.0, y: 0.5)
            leftLineGradientMaskNew.endPoint = CGPoint(x: 0.0, y: 0.5)
            leftLineGradientMaskNew.frame = leftBezier.bounds
            leftLineGradientLayer.mask = leftLineGradientMaskNew
            
            leftLineGradientLayer.fillColor = UIColor.connectingLineColor.cgColor
            leftLineGradientLayer.path = leftBezier.cgPath
            
            // right line
            let rightArcCenter = CGPoint(x: outerShapeMinX + outerShapeWidth - outerShapeHeight / 2, y: self.bounds.midY)
            
            let rightBezier = UIBezierPath(arcCenter: rightArcCenter, radius: arcRadius, startAngle: CGFloat.pi / 6, endAngle: 11 * CGFloat.pi / 6, clockwise: false)
            rightBezier.usesEvenOddFillRule = true
            
            rightBezier.addLine(to: CGPoint(x: self.bounds.width, y: arcMinY))
            
            rightBezier.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - arcMinY))
            
            rightBezier.close()
            
            let rightLineGradientMaskNew = CAGradientLayer()
            rightLineGradientMaskNew.colors = connectGradientColors
            rightLineGradientMaskNew.endPoint = CGPoint(x: 1.0, y: 0.5)
            rightLineGradientMaskNew.startPoint = CGPoint(x: 0.0, y: 0.5)
            rightLineGradientMaskNew.frame = CGRect(x: 0, y: rightBezier.bounds.minY, width: rightBezier.bounds.width, height: rightBezier.bounds.height)
            rightLineGradientLayer.mask = rightLineGradientMaskNew
            
            rightLineGradientLayer.fillColor = UIColor.connectingLineColor.cgColor
            rightLineGradientLayer.path = rightBezier.cgPath
        }
        else {
            self.leftLineGradientLayer.fillColor = UIColor.disconnectedLineColor.cgColor
            self.rightLineGradientLayer.fillColor = UIColor.disconnectedLineColor.cgColor
        }
    }
}
