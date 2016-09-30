//
//  ThemedChangeIPAddressButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedChangeIPAddressButton: UIButton {

    override func awakeFromNib() {
        let image = UIImage(resource: R.image.icon_refresh)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        
        configureView()
    }
    
    func configureView() {
        self.tintColor = UIColor.white
        self.setTitleColor(UIColor.white, for: .normal)
        self.borderColor = UIColor.white
    }

}
