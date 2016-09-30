//
//  ThemedTimeLabelButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedTimeLabelButton: UIButton {
    
    override func awakeFromNib() {
        let image = UIImage(resource: R.image.icon_time)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        
        configureView()
    }
    
    func configureView() {
        self.tintColor = UIColor.blackThemeTextColor()
        self.setTitleColor(UIColor.blackThemeTextColor(), for: .normal)
        self.borderColor = UIColor.blackThemeTextColor()
    }
    
}
