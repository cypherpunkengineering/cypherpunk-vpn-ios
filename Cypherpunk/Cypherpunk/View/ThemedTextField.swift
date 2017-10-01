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
        
        let clearButton = UIButton(type: .custom)
        clearButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        clearButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
        clearButton.setTitle(String.fontAwesomeIcon(code: "fa-times-circle"), for: .normal)
        clearButton.setTitleColor(UIColor.greenyBlue, for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)

        self.rightView = clearButton
        
        self.rightViewMode = .whileEditing
    }
    
    @IBAction func clearTextField() {
        self.text = ""
    }
}
