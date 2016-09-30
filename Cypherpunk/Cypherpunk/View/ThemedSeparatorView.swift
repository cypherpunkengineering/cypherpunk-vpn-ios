//
//  ThemedSeparatorView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedSeparatorView: UIView {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.30)
    }
}
