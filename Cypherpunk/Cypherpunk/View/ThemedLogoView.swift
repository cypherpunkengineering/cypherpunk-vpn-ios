//
//  ThemedLogoView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedLogoView: UIButton {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let image = UIImage(resource: R.image.logoGray_small)
        self.setImage(image, for: .normal)
        self.setImage(image, for: .disabled)
        self.tintColor = UIColor.white
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
    }
}
