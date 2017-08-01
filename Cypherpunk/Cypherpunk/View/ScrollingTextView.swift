//
//  ScrollingTextView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import MarqueeLabel

class ScrollingTextView: UIView {
    private var topLabel = MarqueeLabel()
    private var bottomLabel = MarqueeLabel()

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
    }
}
