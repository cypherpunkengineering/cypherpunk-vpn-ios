//
//  VPNSwitch.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/11/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

protocol VPNSwitchDelegate: class {
    func stateChanged(on: Bool)
    func shouldChangeSwitchState() -> Bool
}

class VPNSwitch: UIView, UIGestureRecognizerDelegate {
    weak var delegate: VPNSwitchDelegate?
    
    var isOn: Bool = false {
        didSet {
            updateToggle(on: isOn)
        }
    }
    
    private let sliderContainerLayer: CAShapeLayer = CAShapeLayer()
    private let sliderThumbLayer: CAShapeLayer = CAShapeLayer()
    private let thumbGradientLayer: CAGradientLayer = CAGradientLayer()
    private let thumbGradientColors = [
        UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.4).cgColor,
        UIColor(white: 1, alpha: 0).cgColor
    ]
    
    private let containerOffFillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
    private let containerOffStrokeColor = UIColor.disconnectedLineColor.withAlphaComponent(0.5).cgColor
    
    private let containerOnFillColor = UIColor(red: 0.0, green: 91 / 255.0, blue: 91 / 255.0, alpha: 0.5).cgColor
    private let containerOnStrokeColor = UIColor(red: 0.0, green: 175.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0).cgColor
    
    private var isThumbInOnPostion = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSublayers()
    }
    
    private func setupSublayers() {
        self.backgroundColor = UIColor.clear

        // slider container
        sliderContainerLayer.fillColor = containerOffFillColor
        sliderContainerLayer.strokeColor = containerOffStrokeColor
        sliderContainerLayer.lineWidth = 3
        
        let sliderOutlinePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: self.frame.height / 2)
        sliderContainerLayer.path = sliderOutlinePath.cgPath
        
        self.layer.addSublayer(sliderContainerLayer)
        
        // slider thumb
        // base layer for thumb
        sliderThumbLayer.fillColor = UIColor.switchThumbBaseColor.cgColor
        
        let thumbDiameter = self.frame.height - 10
        let thumbOutlinePath = UIBezierPath(ovalIn: CGRect(x: 4, y: 5, width: thumbDiameter, height: thumbDiameter))
        sliderThumbLayer.path = thumbOutlinePath.cgPath
        
        // create inner gradient circle
        thumbGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        thumbGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        thumbGradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        
        thumbGradientLayer.colors = thumbGradientColors
        
        let gradientLayerMask = CAShapeLayer()
        gradientLayerMask.path = UIBezierPath(ovalIn: CGRect(x: 8, y: 9, width: thumbDiameter - 8, height: thumbDiameter - 8)).cgPath
        
        thumbGradientLayer.mask = gradientLayerMask
        
        sliderThumbLayer.addSublayer(thumbGradientLayer)
        
        self.layer.addSublayer(sliderThumbLayer)
        
        // add touch handler
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
    }

    @IBAction func updateToggle(on: Bool) {
        // don't animate the button to the same state
        if isThumbInOnPostion == on {
            return
        }
        
        let thumbDiameter = self.frame.height - 10
        let onXCoord = self.frame.width - thumbDiameter - 8
        
        if on {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = [0, 0]
            animation.toValue = [onXCoord, 0]
            animation.duration = 0.5
            
            let toColors: [AnyObject] = [UIColor.white.cgColor, UIColor.white.cgColor]
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = thumbGradientLayer.colors
            colorAnimation.toValue = toColors
            colorAnimation.duration = 0.8
            colorAnimation.isRemovedOnCompletion = true
            colorAnimation.fillMode = kCAFillModeForwards
            colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            //animation.delegate = self
            
            let thumbFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
            thumbFillColorAnimation.fromValue = sliderThumbLayer.fillColor
            thumbFillColorAnimation.toValue = UIColor.connectGlowColor.cgColor
            
            let containerFillColorAnim = CABasicAnimation(keyPath: "fillColor")
            containerFillColorAnim.fromValue = containerOffFillColor
            containerFillColorAnim.toValue = containerOffFillColor
            
            sliderContainerLayer.add(containerFillColorAnim, forKey: "fillColor")
            sliderThumbLayer.add(animation, forKey: "position")
            thumbGradientLayer.add(colorAnimation, forKey: "animateGradient")
            sliderThumbLayer.add(thumbFillColorAnimation, forKey: "fillColor")
            
            sliderContainerLayer.fillColor = containerOnFillColor
            sliderContainerLayer.strokeColor = containerOnFillColor
            thumbGradientLayer.colors = toColors
            sliderThumbLayer.position = CGPoint(x: onXCoord, y: 0)
            sliderThumbLayer.fillColor = UIColor.connectGlowColor.cgColor
            
            isThumbInOnPostion = true
        }
        else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = [onXCoord, 0]
            animation.toValue = [0, 0]
            animation.duration = 0.5
            
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = thumbGradientLayer.colors
            colorAnimation.toValue = thumbGradientColors
            colorAnimation.duration = 0.8
            colorAnimation.isRemovedOnCompletion = true
            colorAnimation.fillMode = kCAFillModeForwards
            colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            //animation.delegate = self
            
            let thumbFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
            thumbFillColorAnimation.fromValue = sliderThumbLayer.fillColor
            thumbFillColorAnimation.toValue = UIColor.connectGlowColor.cgColor
            
            let containerFillColorAnim = CABasicAnimation(keyPath: "fillColor")
            containerFillColorAnim.fromValue = containerOnFillColor
            containerFillColorAnim.toValue = containerOffFillColor
            
            sliderContainerLayer.add(containerFillColorAnim, forKey: "fillColor")
            sliderThumbLayer.add(animation, forKey: "position")
            thumbGradientLayer.add(colorAnimation, forKey: "animateGradient")
            sliderThumbLayer.add(thumbFillColorAnimation, forKey: "fillColor")
            
            sliderContainerLayer.fillColor = containerOffFillColor
            sliderContainerLayer.strokeColor = containerOffStrokeColor
            thumbGradientLayer.colors = thumbGradientColors
            sliderThumbLayer.position = CGPoint(x: 0, y: 0)
            sliderThumbLayer.fillColor = UIColor.switchThumbBaseColor.cgColor
            
            isThumbInOnPostion = false
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if let vpnDelegate = delegate {
            if vpnDelegate.shouldChangeSwitchState() {
                toggleSwitch()
            }
        }
        else {
            // no delegate, just toggle the switch
            toggleSwitch()
        }
    }
    
    private func toggleSwitch() {
        isOn = !isOn
        delegate?.stateChanged(on: isOn) // only call if triggered by user
    }
}
