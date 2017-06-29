//
//  LocationButton.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/20/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import Cartography
import FontAwesome_swift

protocol LocationButtonDelgate {
    func buttonPressed()
}

class LocationButton: UIView {
    
    var location: Region? {
        didSet {
            if let loc = self.location {
                self.flagView.image = UIImage(named: loc.country.lowercased())
                self.labelView.text = loc.name
                
                self.labelView.sizeToFit() // resizes label to text length
                self.setNeedsLayout() // causes views to be layed out again using constraints
                self.setNeedsDisplay() // causes a redraw, needed for the background layers
            }
        }
    }
    
    var delegate: LocationButtonDelgate?
    
    var flagView: UIImageView = UIImageView()
    var labelView: UILabel = UILabel()
    var decoratorView = UIView()
    
    var backgroundLayer: CAShapeLayer?
    var shadowLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.flagView)
        self.addSubview(self.labelView)
        
        // setup flag image view
        self.flagView.contentMode = .center

        constrain(self, self.flagView) { parentView, childView in
            childView.height == self.bounds.height
            childView.width == 25.0
            childView.centerY == parentView.centerY + 2
            childView.leading == parentView.leading + 15
        }

        // setup the label
        self.labelView.font = R.font.dosisMedium(size: 16)
        self.labelView.textColor = UIColor.white
        constrain(self, self.labelView, self.flagView) { parentView, childView, flagView in
            childView.height == self.bounds.height
            childView.centerY == parentView.centerY + 2
            childView.leading == flagView.trailing + 10
        }
        
        self.setupDecoratorView()
    }
    
    private func setupDecoratorView() {
        self.addSubview(self.decoratorView)
        
        let height = self.bounds.height
        let halfHeight = height / 2
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.25).cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: height, height: height)
        
        let gradientMaskPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: height, height: height), cornerRadius: halfHeight)
        let gradientLayerMask = CAShapeLayer()
        gradientLayerMask.path = gradientMaskPath.cgPath
        gradientLayer.mask = gradientLayerMask
        
        let chevronString = String.fontAwesomeIcon(name: .chevronRight)
        let chevronRect = (chevronString as NSString).boundingRect(with: CGSize(), options: NSStringDrawingOptions.truncatesLastVisibleLine, attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16)], context: nil)
        let chevronLayer = CATextLayer()
        chevronLayer.font = UIFont.fontAwesome(ofSize: 16)
        chevronLayer.fontSize = 16
        chevronLayer.string = String.fontAwesomeIcon(name: .chevronRight)
        chevronLayer.alignmentMode = kCAAlignmentCenter
        chevronLayer.frame = chevronRect
        chevronLayer.foregroundColor = UIColor.greenyBlue.cgColor
        chevronLayer.position = CGPoint(x: ceil(gradientLayer.frame.width / 2) + 2, y: gradientLayer.frame.height / 2)
        chevronLayer.contentsScale = UIScreen.main.scale
        
        gradientLayer.addSublayer(chevronLayer)
        self.decoratorView.layer.addSublayer(gradientLayer)
        
        constrain(self, self.decoratorView, self.labelView) { parentView, childView, label in
            childView.height == self.bounds.height
            childView.width == self.bounds.height // making it a squaure based on the height
            childView.centerY == parentView.centerY + 2
            childView.leading == label.trailing + 10
            childView.trailing == parentView.trailing - 2
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if self.shadowLayer == nil {
            let shadowLayerPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width + 4, height: self.bounds.height + 4), cornerRadius: (self.bounds.height + 10) / 2)
            self.shadowLayer = CAShapeLayer()
            self.shadowLayer?.path = shadowLayerPath.cgPath
            self.shadowLayer?.strokeColor = UIColor(white: 0.0, alpha: 0.1).cgColor
            self.shadowLayer?.fillColor = nil
            self.shadowLayer?.lineWidth = 4
            self.shadowLayer?.opacity = 0.5
        }
        else {
            let shadowLayerPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width + 4, height: self.bounds.height + 4), cornerRadius: (self.bounds.height + 10) / 2)
            self.shadowLayer?.path = shadowLayerPath.cgPath
        }
        
        if self.backgroundLayer == nil {
            let bglayerPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width, height: self.bounds.height), cornerRadius: self.bounds.height / 2)
            self.backgroundLayer = CAShapeLayer()
            self.backgroundLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.backgroundLayer?.path = bglayerPath.cgPath
            self.backgroundLayer?.fillColor = UIColor(red: 80.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.15).cgColor
            
            self.backgroundLayer?.cornerRadius = self.bounds.height / 2
        }
        else {
            let bglayerPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width, height: self.bounds.height), cornerRadius: self.bounds.height / 2)
            self.backgroundLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.backgroundLayer?.path = bglayerPath.cgPath
        }
        
        self.layer.addSublayer(shadowLayer!)
        self.layer.addSublayer(backgroundLayer!)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        delegate?.buttonPressed()
    }
}
