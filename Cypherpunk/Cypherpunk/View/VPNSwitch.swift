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
}

class VPNSwitch: UIView, UIGestureRecognizerDelegate {
    weak var delegate: VPNSwitchDelegate?
    
    var isOn: Bool = false {
        didSet {
            if oldValue != isOn {
                updateToggle(on: isOn)
                delegate?.stateChanged(on: isOn)
            }
        }
    }
    
    private let sliderContainerLayer: CAShapeLayer = CAShapeLayer()
    private let sliderThumbLayer: CAShapeLayer = CAShapeLayer()
    private let thumbGradientLayer: CAGradientLayer = CAGradientLayer()
    private let thumbGradientColors = [
        UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.4).cgColor,
        UIColor(white: 1, alpha: 0).cgColor
    ]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSublayers()
    }
    
    // TODO make this not reliant on a fixed size
    private func setupSublayers() {
        self.backgroundColor = UIColor.clear
        
        // slider container
        sliderContainerLayer.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        sliderContainerLayer.strokeColor = UIColor(red: 0.0, green: 255.0 / 255.0, blue: 155.0 / 255.0, alpha: 0.2).cgColor
        sliderContainerLayer.lineWidth = 2
        
        let sliderOutlinePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: self.frame.height / 2)
        sliderContainerLayer.path = sliderOutlinePath.cgPath
        
        self.layer.addSublayer(sliderContainerLayer)
        
        // slider thumb
        // base layer for thumb
        sliderThumbLayer.fillColor = UIColor(red: 17.0 / 255.0, green: 119.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0).cgColor
        
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
        let thumbDiameter = self.frame.height - 10
        let onXCoord = self.frame.width - thumbDiameter - 8
        
        if on {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = [0, 0]
            animation.toValue = [onXCoord, 0]
            animation.duration = 1
            
            let toColors: [AnyObject] = [UIColor.white.cgColor, UIColor.white.cgColor]
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = thumbGradientLayer.colors
            colorAnimation.toValue = toColors
            colorAnimation.duration = 0.8
            colorAnimation.isRemovedOnCompletion = true
            colorAnimation.fillMode = kCAFillModeForwards
            colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            //animation.delegate = self
            thumbGradientLayer.colors = toColors
            
            sliderThumbLayer.add(animation, forKey: "position")
            thumbGradientLayer.add(colorAnimation, forKey: "animateGradient")
            
            sliderThumbLayer.position = CGPoint(x: onXCoord, y: 0)
        }
        else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = [onXCoord, 0]
            animation.toValue = [0, 0]
            animation.duration = 1
            
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = thumbGradientLayer.colors
            colorAnimation.toValue = thumbGradientColors
            colorAnimation.duration = 0.8
            colorAnimation.isRemovedOnCompletion = true
            colorAnimation.fillMode = kCAFillModeForwards
            colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            //animation.delegate = self
            thumbGradientLayer.colors = thumbGradientColors
            
            sliderThumbLayer.add(animation, forKey: "position")
            thumbGradientLayer.add(colorAnimation, forKey: "animateGradient")
            
            sliderThumbLayer.position = CGPoint(x: 0, y: 0)
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        isOn = !isOn
    }
}
