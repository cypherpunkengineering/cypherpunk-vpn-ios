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
    case freePremium
    case monthly
    case semiannually
    case annually
    
    var title: String {
        switch self {
        case .free: return "Free"
        case .freePremium: return "Free Premium"
        case .monthly: return "Monthly Premium"
        case .semiannually: return "6 Monthly Premium"
        case .annually: return "Yearly Premium"
        }
    }
    
    var detailMessage: String {
        switch self {
        case .free: return ""
        case .freePremium: return "Expired At"
        default: return "Renews On"
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
        static let password = "password"
        static let secret = "secret"
        static let session = "session"
        static let nickName = "nickName"
        static let rawSubscriptionType = "rawSubscriptionType"
        static let expiredDate = "expiredDate"
    }

    var isLoggedIn: Bool
    var mailAddress: String?
    var password: String?
    var secret: String?
    var session: String?
    var nickName: String?
    var subscriptionType: SubscriptionType
    var expiredDate: Date?
    
    func save() {
        let keychain = Keychain(service: mailAddress!)
        keychain[AccountStateKey.isLoggedIn] = String(isLoggedIn)
        keychain[AccountStateKey.mailAddress] = mailAddress
        keychain[AccountStateKey.password] = password
        keychain[AccountStateKey.secret] = secret
        keychain[AccountStateKey.session] = session
        keychain[AccountStateKey.nickName] = nickName
        keychain[AccountStateKey.rawSubscriptionType] = String(subscriptionType.rawValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
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
        var state = AccountState(isLoggedIn: false, mailAddress: nil, password: nil, secret: nil, session: nil, nickName: nil, subscriptionType: .free, expiredDate: nil)
        let defaults = UserDefaults.standard
        if let service = defaults.string(forKey: AccountStateKey.mailAddress) {
            let keychain = Keychain(service: service)
            state.isLoggedIn = Bool(keychain[AccountStateKey.isLoggedIn] ?? "false")!
            state.mailAddress = keychain[AccountStateKey.mailAddress]
            state.password = keychain[AccountStateKey.password]
            state.secret = keychain[AccountStateKey.secret]
            state.session = keychain[AccountStateKey.session]
            state.nickName = keychain[AccountStateKey.nickName]
            state.subscriptionType = SubscriptionType(rawValue: Int(keychain[AccountStateKey.rawSubscriptionType] ?? "\( SubscriptionType.free.rawValue)")!)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
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
