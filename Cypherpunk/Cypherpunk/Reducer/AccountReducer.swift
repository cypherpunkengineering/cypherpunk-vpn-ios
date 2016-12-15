//
//  accountReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

struct AccountReducer {
    typealias ReducerStateType = AccountState
    
    func handleAction(action: Action, state: AccountState?) -> AccountState {
        
        var accountState = state ?? AccountState(isLoggedIn: false, mailAddress: nil, vpnUsername: nil, vpnPassword: nil, secret: nil, session: nil, nickName: nil, subscriptionType: .free, expiredDate: nil, accountType: nil)
        
        guard let accountAction = action as? AccountAction else {
            return accountState
        }
        
        switch accountAction {
        case .signUp(let mailAddress, let session):
            accountState.isLoggedIn = false
            accountState.mailAddress = mailAddress
            accountState.session = session
            accountState.vpnUsername = nil
            accountState.vpnPassword = nil
            
            accountState.save()
        case .login(let response):
            accountState.isLoggedIn = true
            
            accountState.mailAddress = response.account.email
            accountState.vpnUsername = response.privacy.username
            accountState.vpnPassword = response.privacy.password
            accountState.secret = response.secret
            accountState.session = response.session
            accountState.accountType = response.account.type
            let status = response.subscription
            if response.account.type == "Free" {
                accountState.subscriptionType = .free
                accountState.expiredDate = nil
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                switch status.renewal {
                case "none":
                    accountState.subscriptionType = .free
                    accountState.expiredDate = dateFormatter.date(from: status.expiration)
                case "monthly":
                    accountState.subscriptionType = .monthly
                    accountState.expiredDate = dateFormatter.date(from: status.expiration)
                case "semiannually":
                    accountState.subscriptionType = .semiannually
                    accountState.expiredDate = dateFormatter.date(from: status.expiration)
                case "annually":
                    accountState.subscriptionType = .annually
                    accountState.expiredDate = dateFormatter.date(from: status.expiration)
                case "forever":
                    accountState.subscriptionType = .lifetime
                    accountState.expiredDate = dateFormatter.date(from: status.expiration)
                default:
                    accountState.subscriptionType = .free
                    accountState.expiredDate = nil
                }
            }
            
            accountState.save()
        case .logout:
            accountState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
            VPNConfigurationCoordinator.removeFromPreferences()
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
        case .changeEmail(let newEmail):
            accountState.mailAddress = newEmail
        case .changePassword(_):
            break
        }
        
        return accountState
    }
    
}

