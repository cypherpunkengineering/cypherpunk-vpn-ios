//
//  LoginAction.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import ReSwift

enum LoginAction: Action {
    case SignUp(mailAddress: String)
    case Activate(mailAddress: String, password: String)
    case Login(mailAddress: String, password: String)
    case Logout
}