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
    case free
    case premium
    case family
    case enterprise
    case staff
    case developer
    case monthly
    case semiannually
    case annually
    case lifetime
    case forever
    
    var title: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .family: return "Family"
        case .enterprise: return "Enterprise"
        case .staff: return "Staff"
        case .developer: return "Developer"
        default:
            return "Special"
        }
    }
    
    var detailMessage: String {
        switch self {
        case .free: return ""
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
		default:
			return ""
        }
    }
    
    var subscriptionProductId : String! {
        guard let AppBundleID = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        switch self {
        case .monthly, .semiannually, .annually:
            return AppBundleID + "." + "iTunes_" + self.planId
        default:
            return nil
        }
    }
    
    var planId: String! {
        switch self {
        case .monthly:
            return "monthly899"
        case .semiannually:
            return "semiannually4499"
        case .annually:
            return "annually5999"
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
    var subscriptionType: SubscriptionType
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

        keychain[AccountStateKey.rawSubscriptionType] = String(subscriptionType.rawValue)
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
        var state = AccountState(isLoggedIn: false, mailAddress: nil, vpnUsername: nil, vpnPassword: nil, secret: nil, session: nil, nickName: nil, subscriptionType: .free, expiredDate: nil, accountType: nil)
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

            state.subscriptionType = SubscriptionType(rawValue: Int(keychain[AccountStateKey.rawSubscriptionType] ?? "\( SubscriptionType.free.rawValue)")!)!
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
