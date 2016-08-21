//
//  LoginReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct LoginReducer: Reducer {
    func handleAction(action: Action, state: LoginState?) -> LoginState {
        
        var loginState = state ?? LoginState(isLoggedIn: false, mailAddress: "", password: "", secret: "")
        
        guard let loginAction = action as? LoginAction else {
            return loginState
        }
        
        switch loginAction {
        case .SignUp(let mailAddress):
            loginState.isLoggedIn = false
            loginState.mailAddress = mailAddress
            loginState.password = ""
        case .Activate(let mailAddress, let password):
            loginState.isLoggedIn = true
            loginState.mailAddress = mailAddress
            loginState.password = password
        case .Login(let response):
            loginState.isLoggedIn = true
            loginState.mailAddress = response.account.email
            loginState.secret = response.secret
        case .Logout:
            loginState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
        }
        
        return loginState
    }
    
}

