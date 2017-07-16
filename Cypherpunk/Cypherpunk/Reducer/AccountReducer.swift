//
//  accountReducer.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift
import APIKit

struct AccountReducer {
    typealias ReducerStateType = AccountState
    
    func handleAction(action: Action, state: AccountState?) -> AccountState {
        
        var accountState = state ?? AccountState(isLoggedIn: false, mailAddress: nil, vpnUsername: nil, vpnPassword: nil, secret: nil, session: nil, nickName: nil, subscriptionType: nil, subscriptionRenews: false, subscriptionActive: false, expiredDate: nil, accountType: nil, certificate: nil)
        
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
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            
            accountState.expiredDate = dateFormatter.date(from: status.expiration)
            switch status.type.lowercased() {
            case "none":
                accountState.subscriptionType = nil
            case "monthly":
                accountState.subscriptionType = .monthly
            case "semiannually":
                accountState.subscriptionType = .semiannually
            case "annually":
                accountState.subscriptionType = .annually
            case "lifetime":
                accountState.subscriptionType = .lifetime
            case "forever":
                accountState.subscriptionType = .forever
            case "12m":
                accountState.subscriptionType = .twelveMonths
            case "1y":
                accountState.subscriptionType = .oneYear
            case "6m":
                accountState.subscriptionType = .sixMonths
            case "3m":
                accountState.subscriptionType = .threeMonths
            case "1m":
                accountState.subscriptionType = .oneMonth
            default:
                accountState.subscriptionType = nil
                accountState.expiredDate = nil
            }
            
            accountState.subscriptionRenews = response.subscription.renews
            accountState.subscriptionActive = response.subscription.active
            
            accountState.save()
        case .logout:
            accountState.isLoggedIn = false
            VPNConfigurationCoordinator.disconnect()
            VPNConfigurationCoordinator.removeFromPreferences()
            AccountState.removeLastLoggedInService()
        case .upgrade(let subscription, let expiredDate):
            switch subscription {
            case .none:
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
        case .certificate(let p12):
            accountState.certificate = p12
            accountState.save()
        }
        
        return accountState
    }
    
}

