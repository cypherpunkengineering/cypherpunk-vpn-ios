//
//  ThemedSettingsTabButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedSettingsTabButton: UIButton {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
}
