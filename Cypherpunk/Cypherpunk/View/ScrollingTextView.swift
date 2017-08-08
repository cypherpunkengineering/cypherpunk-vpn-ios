//
//  ScrollingTextView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import MarqueeLabel
import Cartography

class ScrollingTextView: UIView {
    private let topLabel = MarqueeLabel()
    private let bottomLabel = MarqueeLabel()
    
    private let gradientFadeLayer = CAGradientLayer()
    private let blackLineLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.loginBgColor
        
        self.layer.addSublayer(self.blackLineLayer)
        updateLineLayerPath()
        
        topLabel.font = ScrollingTextHelper.marqueeFont
        bottomLabel.font = ScrollingTextHelper.marqueeFont
        
        topLabel.textColor = UIColor.greenyBlue
        bottomLabel.textColor = UIColor.disconnectedLineColor
        
        topLabel.type = .continuous
        bottomLabel.type = .continuousReverse
        
        topLabel.animationDelay = 0.0
        topLabel.speed = .duration(30.0)
        
        bottomLabel.animationDelay = 0.0
        bottomLabel.speed = .duration(30.0)
        
        topLabel.fadeLength = 5.0
        bottomLabel.fadeLength = 5.0
        
        topLabel.text = ScrollingTextHelper.upperText()
        bottomLabel.text = ScrollingTextHelper.lowerText()
        
        self.addSubview(topLabel)
        self.addSubview(bottomLabel)
        
        constrain(self, topLabel) { (parentView, childView) in
            childView.top == parentView.top // need to clear the black line
            childView.height == 20
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
        }

        constrain(self, bottomLabel) { (parentView, childView) in
            childView.bottom == parentView.bottom
            childView.height == 20
            childView.leading == parentView.leading
            childView.trailing == parentView.trailing
        }
        
        self.layer.masksToBounds = false;
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = UIColor.black.cgColor
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        
        self.gradientFadeLayer.colors = [UIColor.black.withAlphaComponent(0.5), UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.5)]
        self.gradientFadeLayer.locations = [0, 0.3, 0.7, 1]
        self.gradientFadeLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientFadeLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.gradientFadeLayer.frame = self.bounds
        self.layer.mask = self.gradientFadeLayer
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == self.layer {
            updateLineLayerPath()
            
            topLabel.text = ScrollingTextHelper.upperText()
            bottomLabel.text = ScrollingTextHelper.lowerText()
            
            self.gradientFadeLayer.frame = self.bounds
        }
    }
    
    private func updateLineLayerPath() {
        // create black line at the top of the view
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        self.blackLineLayer.lineWidth = 4
        self.blackLineLayer.strokeColor = UIColor.black.cgColor
        self.blackLineLayer.path = linePath.cgPath
    }
}
