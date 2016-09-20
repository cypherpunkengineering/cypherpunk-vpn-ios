//
//  SpecificDataProvider.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/15.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import CoreTelephony

struct SpecificDataProvider {
    static func deviceName() -> String {
        let hardware = DeviceGuru.hardware()
        return hardware.name
    }
    static func carrierName() -> String? {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        return carrier?.carrierName
    }
}

extension Hardware {
    var name: String {
        switch self {
        case .not_AVAILABLE:
            return "Not Available"
        case .iphone_2G, .iphone_3G, .iphone_3GS, .iphone_4, .iphone_4_CDMA:
            return "Not Supported"
        case .iphone_4S:
            return "iPhone4S"
        case .iphone_5, .iphone_5_CDMA_GSM:
            return "iPhone5"
        case .iphone_5C, .iphone_5C_CDMA_GSM:
            return "iPhone5c"
        case .iphone_5S, .iphone_5S_CDMA_GSM:
            return "iPhone5s"
        case .iphone_6:
            return "iPhone6"
        case .iphone_6_PLUS:
            return "iPhone6Plus"
        case .iphone_6S:
            return "iPhone6S"
        case .iphone_6S_PLUS:
            return "iPhone6SPlus"
        case .iphone_SE:
            return "iPhoneSE"
        default:
            return "Not Supported"
        }
    }
}
