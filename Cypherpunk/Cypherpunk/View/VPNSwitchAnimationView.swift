//
//  VPNSwitchAnimationView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/19/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import Cartography
import MarqueeLabel

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
    let leftLineShapeLayer = CAShapeLayer()
    let rightLineShapeLayer = CAShapeLayer()
    let leftLineGradientLayer = CAGradientLayer()
    let rightLineGradientLayer = CAGradientLayer()
    
    let chaserGradientLayer = CAGradientLayer()
    let switchGlowShapeLayer = CAShapeLayer()
    
    let topMarqueeLabel = MarqueeLabel()
    let bottomMarqueeLabel = MarqueeLabel()
    
    var originalCurvedPath: UIBezierPath?
    
    let disconnectGradientColors = [UIColor.disconnectedLineColor.cgColor, UIColor.disconnectedLineColor.withAlphaComponent(0.7).cgColor, UIColor.disconnectedLineColor.withAlphaComponent(0.2).cgColor] as [Any]
    
    let connectGradientColors = [UIColor.connectingLineColor.cgColor, UIColor.connectingLineColor.withAlphaComponent(0.7).cgColor, UIColor.connectingLineColor.withAlphaComponent(0.2).cgColor] as [Any]

    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLineLayers()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationWillEnterForeground(_:)),
                                               name:NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationDidEnterBackground(_:)),
                                               name:NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)

        
        self.addSubview(self.vpnSwitch)
        constrain(self, self.vpnSwitch) { parentView, childView in
            childView.height == self.vpnSwitch.frame.height
            childView.width == self.vpnSwitch.frame.width
            childView.centerX == parentView.centerX
            childView.centerY == parentView.centerY
        }

        self.layer.addSublayer(leftLineGradientLayer)
        self.layer.addSublayer(rightLineGradientLayer)
        self.layer.addSublayer(switchGlowShapeLayer)
        
        topMarqueeLabel.frame = CGRect(x: 0, y: 20, width: 300, height: 20)
        topMarqueeLabel.text = ScrollingTextHelper.upperText()
        topMarqueeLabel.fadeLength = 5.0
        topMarqueeLabel.type = .continuous
        topMarqueeLabel.animationDelay = 0.0
        topMarqueeLabel.speed = .duration(30.0)
        topMarqueeLabel.font = ScrollingTextHelper.marqueeFont
        topMarqueeLabel.textColor = UIColor(hex: "#7ffffb", alpha: 1.0)
        topMarqueeLabel.layer.opacity = 0.0
        
        bottomMarqueeLabel.frame = CGRect(x: 0, y: 40, width: 300, height: 20)
        bottomMarqueeLabel.text = ScrollingTextHelper.lowerText()
        bottomMarqueeLabel.fadeLength = 5.0
        bottomMarqueeLabel.type = .continuousReverse
        bottomMarqueeLabel.animationDelay = 0.0
        bottomMarqueeLabel.speed = .duration(30.0)
        bottomMarqueeLabel.font = ScrollingTextHelper.marqueeFont
        bottomMarqueeLabel.textColor = UIColor(hex: "#5fbfbb", alpha: 1.0)
        bottomMarqueeLabel.layer.opacity = 0.0
        
        self.insertSubview(self.topMarqueeLabel, belowSubview: self.vpnSwitch)
        constrain(self, self.topMarqueeLabel) { parentView, childView in
            childView.height == 20
            childView.top == parentView.top + 20
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
        }
        
        self.insertSubview(self.bottomMarqueeLabel, belowSubview: self.vpnSwitch)
        constrain(self, self.bottomMarqueeLabel) { parentView, childView in
            childView.height == 20
            childView.bottom == parentView.bottom - 20
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
        }
        
        setupLineLayers()
    }
    
    private func setupLineLayers() {
        leftLineGradientLayer.frame = self.bounds
        leftLineGradientLayer.locations = [0.5, 0.8, 1.0]
        leftLineGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        leftLineGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        leftLineGradientLayer.mask = leftLineShapeLayer
        
        rightLineGradientLayer.frame = self.bounds
        rightLineGradientLayer.locations = [0.5, 0.8, 1.0]
        rightLineGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        rightLineGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        rightLineGradientLayer.mask = rightLineShapeLayer
        
        transitionToDisconnected(animate: false)
    }
    
    private func transitionToDisconnected(animate: Bool) {
        transformShapeAroundSwitch(connect: false, animate: animate)
        
        transformLine(connect: false, animate: animate)
        
        // marquee labels
        self.topMarqueeLabel.layer.opacity = 0.0
        self.bottomMarqueeLabel.layer.opacity = 0.0
    }
    
    func beginConnectAnimation() {
        transformShapeAroundSwitch(connect: true)
        
        self.leftLineGradientLayer.colors = self.connectGradientColors
        self.rightLineGradientLayer.colors = self.connectGradientColors
        
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
    
    private func transformShapeAroundSwitch(connect: Bool, animate: Bool = true) {
        if connect {
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
            
            if animate {
                let switchGlowPathAnimation = CABasicAnimation(keyPath: "path")
                switchGlowPathAnimation.fromValue = self.switchGlowShapeLayer.path
                switchGlowPathAnimation.toValue = bezierPath.cgPath
                switchGlowPathAnimation.duration = 0.3
                
                let switchGlowFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
                switchGlowFillColorAnimation.fromValue = self.switchGlowShapeLayer.fillColor
                switchGlowFillColorAnimation.toValue = UIColor.connectGlowColor.cgColor
                switchGlowFillColorAnimation.duration = 0.1
                
                let switchGlowAnimationGroup = CAAnimationGroup()
                switchGlowAnimationGroup.animations = [
                    switchGlowPathAnimation,
                    switchGlowFillColorAnimation
                ]
                
                self.switchGlowShapeLayer.add(switchGlowAnimationGroup, forKey: "switchGlowAnimation")
            }
            
            self.switchGlowShapeLayer.path = bezierPath.cgPath
            self.switchGlowShapeLayer.fillColor = UIColor.connectGlowColor.cgColor
        }
        else {
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
            
            if animate {
                let glowPathAnim = createPathChangeAnimation(currentPath: switchGlowShapeLayer.path, newPath: bezierPath.cgPath)
                glowPathAnim.beginTime = 0.5
                
                let fillColorAnim = createFillColorAnimation(currentColor: switchGlowShapeLayer.fillColor, newColor: UIColor.disconnectedLineColor.cgColor)
                fillColorAnim.beginTime = 0.0
                
                let animGroup = CAAnimationGroup()
                animGroup.animations = [glowPathAnim, fillColorAnim]
                animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                
                self.switchGlowShapeLayer.add(animGroup, forKey: "glowLayerAnim")
            }
            
            self.switchGlowShapeLayer.path = bezierPath.cgPath
            self.switchGlowShapeLayer.fillColor = UIColor.disconnectedLineColor.cgColor
            self.switchGlowShapeLayer.fillRule = kCAFillRuleEvenOdd
            
            self.originalCurvedPath = bezierPath
        }
    }
    
    func cancelConnectAnimation() {
        transformLine(connect: false)
        
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
        transformShapeAroundSwitch(connect: true)
        transformLine(connect: true)
        
        self.chaserGradientLayer.removeAnimation(forKey: "heartbeatAnimation")
        self.chaserGradientLayer.removeFromSuperlayer()
    }
    
    private func transformLine(connect: Bool, animate: Bool = true) {
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
            
            leftBezier.close()
            
            let leftLineGradientAnimation = createGradientChangeAnimation(useConnectColors: true)
            let leftPathChangeAnimation = createPathChangeAnimation(currentPath: leftLineShapeLayer.path!, newPath: leftBezier.cgPath)
            
//            leftLineShapeLayer.add(leftPathChangeAnimation, forKey: "path")
            leftLineGradientLayer.add(leftLineGradientAnimation, forKey: "colors")
            
            leftLineGradientLayer.colors = connectGradientColors
            leftLineShapeLayer.path = leftBezier.cgPath
            leftLineGradientLayer.mask = leftLineShapeLayer
            
            // right line
            let rightArcCenter = CGPoint(x: outerShapeMinX + outerShapeWidth - outerShapeHeight / 2, y: self.bounds.midY)
            
            let rightBezier = UIBezierPath(arcCenter: rightArcCenter, radius: arcRadius, startAngle: CGFloat.pi / 6, endAngle: 11 * CGFloat.pi / 6, clockwise: false)
            rightBezier.usesEvenOddFillRule = true
            
            rightBezier.addLine(to: CGPoint(x: self.bounds.width, y: arcMinY))
            
            rightBezier.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - arcMinY))
            
            rightBezier.close()

            let rightLineGradientAnimation = createGradientChangeAnimation(useConnectColors: true)
            let rightPathChangeAnimation = createPathChangeAnimation(currentPath: rightLineShapeLayer.path!, newPath: rightBezier.cgPath)
            
//            rightLineShapeLayer.add(rightPathChangeAnimation, forKey: "path")
            rightLineGradientLayer.add(rightLineGradientAnimation, forKey: "colors")
            
            rightLineGradientLayer.colors = connectGradientColors
            rightLineShapeLayer.path = rightBezier.cgPath
            rightLineGradientLayer.mask = rightLineShapeLayer
            
            // marquee labels
            self.topMarqueeLabel.layer.add(createShowHideAnimation(show: true), forKey: "opacity")
            self.bottomMarqueeLabel.layer.add(createShowHideAnimation(show: true), forKey: "opacity")
            
            self.topMarqueeLabel.layer.opacity = 1.0
            self.bottomMarqueeLabel.layer.opacity = 1.0
        }
        else {
            
            let widthBetweenSwitchAndEdge = (self.frame.width - self.vpnSwitch.frame.width) / 2
            
            // left of the switch
            let leftLinePath = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight))
        
            let leftLineGradientAnimation = createGradientChangeAnimation(useConnectColors: false)
            let leftPathChangeAnimation = createPathChangeAnimation(currentPath: leftLineShapeLayer.path, newPath: leftLinePath.cgPath)
            
            leftLineShapeLayer.add(leftPathChangeAnimation, forKey: "path")
            leftLineGradientLayer.add(leftLineGradientAnimation, forKey: "colors")
            
            leftLineGradientLayer.colors = disconnectGradientColors
            leftLineShapeLayer.path = leftLinePath.cgPath
            
            
            // right of the switch
            let rightLinePath = UIBezierPath(rect: CGRect(x: self.bounds.width - widthBetweenSwitchAndEdge + 10, y: self.bounds.height / 2.0 - nonConnectedLineHeight / 2.0, width: widthBetweenSwitchAndEdge - 10, height: nonConnectedLineHeight))
            
            let rightLineGradientAnimation = createGradientChangeAnimation(useConnectColors: false)
            let rightPathChangeAnimation = createPathChangeAnimation(currentPath: rightLineShapeLayer.path, newPath: rightLinePath.cgPath)
            
            rightLineShapeLayer.add(rightPathChangeAnimation, forKey: "path")
            rightLineGradientLayer.add(rightLineGradientAnimation, forKey: "colors")
            
            rightLineGradientLayer.colors = disconnectGradientColors
            rightLineShapeLayer.path = rightLinePath.cgPath
            
            self.topMarqueeLabel.layer.opacity = 0.0
            self.bottomMarqueeLabel.layer.opacity = 0.0
        }
    }
    
    private func createShowHideAnimation(show: Bool) -> CAAnimation {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        
        if show {
            animation.fromValue = 0.0
            animation.toValue = 1.0
        }
        else {
            animation.fromValue = 1.0
            animation.toValue = 0.0
        }
        animation.duration = 0.2
        
        return animation
    }
    
    private func createGradientChangeAnimation(useConnectColors: Bool) -> CAAnimation {
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        
        if useConnectColors {
            colorChangeAnimation.fromValue = disconnectGradientColors
            colorChangeAnimation.toValue = connectGradientColors
        }
        else {
            colorChangeAnimation.fromValue = connectGradientColors
            colorChangeAnimation.toValue = disconnectGradientColors
        }
        colorChangeAnimation.duration = 0.3
        
        return colorChangeAnimation
    }
    
    private func createPathChangeAnimation(currentPath: CGPath?, newPath: CGPath) -> CAAnimation {
        let pathChangeAnimation = CABasicAnimation(keyPath: "path")
        pathChangeAnimation.fromValue = currentPath != nil ? currentPath! : nil
        pathChangeAnimation.toValue = newPath
        pathChangeAnimation.duration = 0.3
        
        return pathChangeAnimation
    }
    
    private func createFillColorAnimation(currentColor: CGColor?, newColor: CGColor) -> CAAnimation {
        let fillColorAnim = CABasicAnimation(keyPath: "fillColor")
        fillColorAnim.fromValue = currentColor != nil ? currentColor! : nil
        fillColorAnim.toValue = newColor
        fillColorAnim.duration = 0.3
        
        return fillColorAnim
    }
    
    func applicationWillEnterForeground(_ notification: NSNotification) {
        self.topMarqueeLabel.restartLabel()
        self.bottomMarqueeLabel.restartLabel()
    }
    
    func applicationDidEnterBackground(_ notification: NSNotification) {
        self.topMarqueeLabel.shutdownLabel()
        self.bottomMarqueeLabel.shutdownLabel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}
