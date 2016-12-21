//
//  ThemedLabel.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedLabel: UILabel {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        self.textColor = UIColor.white
    }
    
}
