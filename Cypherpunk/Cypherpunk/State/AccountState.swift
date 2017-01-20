//
//  AccountState.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

import ReSwift

enum SubscriptionType: Int {
    // none is nil
    case monthly
    case semiannually
    case annually
    case lifetime
    case forever
        
    var detailMessage: String {
        switch self {
        case .monthly:
            return "Renews monthly"
        case .semiannually:
            return "Renews semiannually"
        case .annually:
            return "Renews annually"
        case .lifetime:
            return "Lifetime"
        case .forever:
            return "Forever"
        }
    }
    
    var subscriptionProductId : String! {
        switch self {
        case .monthly, .semiannually, .annually:
            return "iTunes_" + self.planId
        default:
            return nil
        }
    }
    
    var planId: String! {
        switch self {
        case .monthly:
            return "monthly1199"
        case .semiannually:
            return "semiannually5899"
        case .annually:
            return "annually9499"
        default:
            return nil
        }
    }
}

import KeychainAccess
struct AccountState: StateType {
    fileprivate struct AccountStateKey {
        static let isLoggedIn = "isLoggedIn"
        static let mailAddress = "mailAddress"
        static let vpnUsername = "vpnUsername"
        static let vpnPassword = "vpnPassword"
        static let secret = "secret"
        static let session = "session"
        static let nickName = "nickName"
        static let rawSubscriptionType = "rawSubscriptionType"
        static let expiredDate = "expiredDate"
        static let accountType = "accountType"

    }

    var isLoggedIn: Bool
    var mailAddress: String?
    var vpnUsername: String?
    var vpnPassword: String?
    var secret: String?
    var session: String?
    var nickName: String?
    var subscriptionType: SubscriptionType?
    var expiredDate: Date?
    var accountType: String?
    
    func save() {
        let keychain = Keychain(service: mailAddress!)
        keychain[AccountStateKey.isLoggedIn] = String(isLoggedIn)
        keychain[AccountStateKey.mailAddress] = mailAddress
        keychain[AccountStateKey.vpnUsername] = vpnUsername
        keychain[AccountStateKey.vpnPassword] = vpnPassword
        keychain[AccountStateKey.secret] = secret
        keychain[AccountStateKey.session] = session
        keychain[AccountStateKey.nickName] = nickName
        keychain[AccountStateKey.accountType] = accountType

        if let subscriptionType = subscriptionType {
            keychain[AccountStateKey.rawSubscriptionType] = String(subscriptionType.rawValue)
        } else {
            keychain[AccountStateKey.rawSubscriptionType] = nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.locale = Locale.current
        if let date = expiredDate {
            let dateString = dateFormatter.string(from: date)
            keychain[AccountStateKey.expiredDate] = dateString
        } else {
            keychain[AccountStateKey.expiredDate] = nil
        }

        
        let defaults = UserDefaults.standard
        defaults.set(mailAddress, forKey: AccountStateKey.mailAddress)
        defaults.synchronize()
    }
    
    static func restore() -> AccountState {
        var state = AccountState(isLoggedIn: false, mailAddress: nil, vpnUsername: nil, vpnPassword: nil, secret: nil, session: nil, nickName: nil, subscriptionType: nil, expiredDate: nil, accountType: nil)
        let defaults = UserDefaults.standard
        if let service = defaults.string(forKey: AccountStateKey.mailAddress) {
            let keychain = Keychain(service: service)
            state.isLoggedIn = Bool(keychain[AccountStateKey.isLoggedIn] ?? "false")!
            state.mailAddress = keychain[AccountStateKey.mailAddress]
            state.vpnUsername = keychain[AccountStateKey.vpnUsername]
            state.vpnPassword = keychain[AccountStateKey.vpnPassword]
            state.secret = keychain[AccountStateKey.secret]
            state.session = keychain[AccountStateKey.session]
            state.nickName = keychain[AccountStateKey.nickName]
            state.accountType = keychain[AccountStateKey.accountType]

            if let rawSubscriptionTypeString = keychain[AccountStateKey.rawSubscriptionType], let rawSubscriptionType = Int(rawSubscriptionTypeString) {
                state.subscriptionType = SubscriptionType(rawValue: rawSubscriptionType)
            } else {
                state.subscriptionType = nil
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            dateFormatter.locale = Locale.current
            if let dateString = keychain[AccountStateKey.expiredDate] {
                state.expiredDate = dateFormatter.date(from: dateString)
            }
        }
        return state
    }
 
    static func removeLastLoggedInService() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: AccountStateKey.mailAddress)
    }
}
