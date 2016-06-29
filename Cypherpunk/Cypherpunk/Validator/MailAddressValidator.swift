//
//  MailAddressValidator.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

func isValidMailAddress(mailAddress: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let validatePredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return validatePredicate.evaluateWithObject(mailAddress)
}