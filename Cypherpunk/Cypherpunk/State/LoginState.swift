//
//  LoginState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct LoginState : StateType {
    var isLoggedIn: Bool
    var mailAddress: String
    var password: String
    var secret: String
}
