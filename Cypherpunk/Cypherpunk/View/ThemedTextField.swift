//
//  ThemedTextField.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedTextField: UITextField {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }
    func configureView() {
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder ?? "",
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.5)])
    }

}
