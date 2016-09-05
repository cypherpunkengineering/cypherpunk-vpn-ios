//
//  accountReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct AccountReducer: Reducer {
    func handleAction(action: Action, state: AccountState?) -> AccountState {
        
        var accountState = state ?? AccountState(isLoggedIn: false, mailAddress: "", password: "", secret: "", nickName: "", subscriptionType: .Free, expiredDate: nil)
        
        guard let accountAction = action as? AccountAction else {
            return accountState
        }
        
        switch accountAction {
        case .SignUp(let mailAddress):
            accountState.isLoggedIn = true
            accountState.mailAddress = mailAddress
            accountState.password = ""
        case .Activate(let mailAddress, let password):
            accountState.isLoggedIn = true
            accountState.mailAddress = mailAddress
            accountState.password = password
        case .Login(let response):
            accountState.isLoggedIn = true
            accountState.mailAddress = response.account.email
            accountState.secret = response.secret
        case .Logout:
            accountState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
        case .Upgrade(let subscription, let expiredDate):
            switch subscription {
            case .Free:
                accountState.expiredDate = nil
            default:
                accountState.subscriptionType = subscription
                accountState.expiredDate = expiredDate
            }
        }
        
        return accountState
    }
    
}

