//
//  BlueButton.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 8/30/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class BlueButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonStyle()
    }
    
    private func setupButtonStyle() {
        self.layer.cornerRadius = 5.0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = UIColor.darkBlueGreyTwo.cgColor
        
        self.setBackgroundColor(color: UIColor.loginButtonColor, forState: .normal)
        
        self.setBackgroundColor(color: UIColor.loginButtonLightColor, forState: .highlighted)
        
        self.setBackgroundColor(color: UIColor.loginButtonColor.darkerColor(percent: 0.2), forState: .disabled)
        
        self.layer.masksToBounds = false
        
        self.setTitleColor(UIColor.white, for: .normal)
    }
}
