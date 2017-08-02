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
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == self.layer {
            updateLineLayerPath()
            
            topLabel.text = ScrollingTextHelper.upperText()
            bottomLabel.text = ScrollingTextHelper.lowerText()
        }
    }
    
    private func updateLineLayerPath() {
        // create black line at the top of the view
        let linePath = UIBezierPath()
        linePath.lineWidth = 10
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        self.blackLineLayer.strokeColor = UIColor.black.cgColor
        self.blackLineLayer.path = linePath.cgPath
    }
}
