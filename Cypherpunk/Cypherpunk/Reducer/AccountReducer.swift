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
    typealias ReducerStateType = AccountState

    func handleAction(action: Action, state: AccountState?) -> AccountState {
        
        var accountState = state ?? AccountState(isLoggedIn: false, mailAddress: nil, password: nil, secret: nil, nickName: nil, subscriptionType: .free, expiredDate: nil)
        
        guard let accountAction = action as? AccountAction else {
            return accountState
        }
        
        switch accountAction {
        case .signUp(let mailAddress):
            accountState.isLoggedIn = true
            accountState.mailAddress = mailAddress
            accountState.password = nil
            
            accountState.save()
        case .activate(let mailAddress, let password):
            accountState.isLoggedIn = true
            accountState.mailAddress = mailAddress
            accountState.password = password
            
            accountState.save()
        case .login(let response):
            accountState.isLoggedIn = true
            accountState.mailAddress = response.account.email
            accountState.secret = response.secret
            
            accountState.save()
        case .logout:
            accountState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
            
            AccountState.removeLastLoggedInService()
        case .upgrade(let subscription, let expiredDate):
            switch subscription {
            case .free:
                accountState.expiredDate = nil
            default:
                accountState.subscriptionType = subscription
                accountState.expiredDate = expiredDate
            }
            
            accountState.save()
        }
        
        return accountState
    }
    
}

