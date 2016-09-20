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
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder ?? "",
                                                                        attributes:[NSForegroundColorAttributeName: UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0)])
        case .black:
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder ?? "",
                                                                        attributes:[NSForegroundColorAttributeName: UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0)])
        case .indigo:
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder ?? "",
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.5)])
        }
    }

}
