//
//  HasShownKeyboardType.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/07/04.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

protocol HasShownKeyboardType {
    var bottomSpaceConstraint: NSLayoutConstraint! {get set}
}

extension HasShownKeyboardType {
    
    func registerKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: #selector(Self.keyboardWillShow(_:)), object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: #selector(Self.keyboardWillHide(_:)), object: nil)
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                bottomSpaceConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        bottomSpaceConstraint.constant = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
    }
}
