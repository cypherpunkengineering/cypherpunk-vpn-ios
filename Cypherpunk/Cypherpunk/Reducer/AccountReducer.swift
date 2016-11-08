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
        
        var accountState = state ?? AccountState(isLoggedIn: false, mailAddress: nil, password: nil, secret: nil, session: nil, nickName: nil, subscriptionType: .free, expiredDate: nil)
        
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
        case .login(let response, let password):
            accountState.isLoggedIn = true
            accountState.mailAddress = response.account.email
            accountState.password = password
            accountState.secret = response.secret
            accountState.session = response.session
            accountState.save()
        case .logout:
            accountState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
            VPNConfigurationCoordinator.removeFromPreferences()
            AccountState.removeLastLoggedInService()
        case .getSubscriptionStatus(let status):
            if status.type == "Free" {
                accountState.subscriptionType = .free
            } else {
                switch status.renewal {
                case "none":
                    accountState.subscriptionType = .freePremium
                case "monthly":
                    accountState.subscriptionType = .monthly
                case "semiannually":
                    accountState.subscriptionType = .semiannually
                case "annually":
                    accountState.subscriptionType = .annually
                default:
                    accountState.subscriptionType = .free
                }
            }
            break
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

