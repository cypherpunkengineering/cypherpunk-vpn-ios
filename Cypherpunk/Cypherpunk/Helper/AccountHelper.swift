//
//  AccountHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/15/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import Foundation

class AccountHelper {
    static var ACCOUNT_TYPE_NAMES = [
        "free": "Trial Account",
        "premium": "Premium Account",
        "family": "Family Account",
        "enterprise": "Enterprise Account",
        "staff": "Staff",
        "developer": "Developer",
        "expired": "Expired Account",
    ]
    
    static var SUBSCRIPTION_SCHEDULE_DAYS: [SubscriptionType:Int] = [
        SubscriptionType.annually: 365,
        SubscriptionType.semiannually: 182,
        SubscriptionType.monthly: 30,
        SubscriptionType.twelveMonths: 365,
        SubscriptionType.oneYear: 365,
        SubscriptionType.sixMonths: 180,
        SubscriptionType.threeMonths: 90,
        SubscriptionType.oneMonth: 30
    ]
    
    static func accountTypeString() -> String {
        let accountState = mainStore.state.accountState
        
        var accountTypeString = ""
        
        if let expDate = accountState.expiredDate, expDate < Date() {
            accountTypeString = ACCOUNT_TYPE_NAMES["expired"]!
        }
        else if let accountType = accountState.accountType {
            let type = ACCOUNT_TYPE_NAMES[accountType]
            if let typeName = type {
                accountTypeString = typeName
            }
        }
        
        return accountTypeString
    }
    
    static func accountExpirationString() -> String {
        let accountState = mainStore.state.accountState
        let expiration = accountState.expiredDate
        
        let type = accountState.accountType
        let plan = accountState.subscriptionType
        
        let renews = accountState.subscriptionRenews
        
        var expirationString: String? = nil
        var expirationClassName: String? = nil
        
        if let exp = expiration {
            let now = Date()
            
            if exp < now {
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "MM/dd/yyyy"
                
                expirationString = "Expired on \(dateFormatterPrint.string(from: exp))"
                expirationClassName = "expired"
            }
            else {
                var planDays = 7
                
                if let accountPlan = plan {
                    let rawDays = SUBSCRIPTION_SCHEDULE_DAYS[accountPlan]
                    if let days = rawDays {
                        planDays = days
                    }
                }
                
                let limitDays = planDays > 30 ? 30 : 7
                
                let cal = NSCalendar.current
                let diff = cal.dateComponents([.day], from: now, to: exp)
                if diff.day! <= limitDays {
                    let prefix = renews ? "Renews " : "Expires "
                    
                    expirationString = "\(prefix)\(describeRelativeDate(date: exp, now: now))"
                }
                
                if !renews && diff.day! <= 7 {
                    expirationClassName = "expiring"
                }
            }
            
            if expirationString != nil && !renews {
                
            }
        }
        else {
            expirationString = "Lifetime"
        }
        
//        if (expirationString != nil && SUBSCRIPTION_SCHEDULE_NAMES.hasOwnProperty(plan)) {
//            expirationString = SUBSCRIPTION_SCHEDULE_NAMES[plan];
//        }
        
        if expirationString == nil {
            expirationString = plan?.detailMessage
        }
        
        return expirationString!
    }
    
    static func describeRelativeDate(date: Date, now: Date) -> String {
        let cal = NSCalendar.current
        let diff = cal.dateComponents([.hour], from: now, to: date)
        var diffHours = diff.hour!
        
        if diffHours < 0 {
            diffHours = abs(diffHours)
            
            if diffHours < 1 {
                return "just now"
            }
            else if diffHours <= 2 {
                return "an hour ago"
            }
            else if diffHours < 6 {
                return "less than 6 hours ago"
            }
            else if diffHours <= 2 * 24 {
                let nowDay = cal.component(.day, from: now)
                let dateDay = cal.component(.day, from: date)
                
                if dateDay == nowDay {
                    return "today"
                }
                
                let yesterday = cal.date(byAdding: .day, value: -1, to: now)
                if dateDay == cal.component(.day, from: yesterday!) {
                    return "yesterday"
                }
            }
            
            if diffHours <= 30 * 24 {
                let daysAgo = ceil(Double(diffHours / 24))
                return String(format: "%.0f days ago", daysAgo)
            }
            else if diffHours <= 50 * 24 {
                let weeksAgo = ceil(Double(diffHours / (7 * 24)))
                return String(format: "%.0f weeks ago", weeksAgo)
            }
            else if diffHours <= 300 * 24 {
                let monthsAgo = ceil(Double(diffHours / (30 * 24)))
                return String(format: "%.0f months ago", monthsAgo)
            }
            else if diffHours <= 400 * 24 {
                return "a year ago"
            }
            else {
                return "over a year ago"
            }
        }
        else {
            if diffHours < 1 {
                return "in less than an hour"
            }
            else if diffHours < 6 {
                return "in less than 6 hours"
            }
            else if diffHours <= 2 * 24 {
                let nowDay = cal.component(.day, from: now)
                let dateDay = cal.component(.day, from: date)
                
                if dateDay == nowDay {
                    return "today"
                }
                
                let tomorrow = cal.date(byAdding: .day, value: 1, to: now)
                if dateDay == cal.component(.day, from: tomorrow!) {
                    return "tomorrow"
                }
            }
            
            if diffHours <= 30 * 24 {
                return String(format: "in %.0f days", ceil(Double(diffHours / 24)))
            }
            else if diffHours <= 50 * 24 {
                return String(format: "in %.0f weeks", ceil(Double(diffHours / 7 * 24)))
            }
            else if diffHours <= 300 * 24 {
                return String(format: "in %.0f months", ceil(Double(diffHours / 30 * 24)))
            }
            else if diffHours <= 400 * 24 {
                return "in one year"
            }
            else {
                return "in over a year"
            }
        }
    }
}
