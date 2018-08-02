//
//  UIViewControllerExtensions.swift
//  Line Up App
//
//  Created by Macbook on 7/26/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

extension UIViewController {
    
    func isNsnullOrNil(_ object : Any?) -> Bool {
        if let _: Any = object {
            return true
        } else { return false }
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func secondsToTime(_ inputSeconds: Int) -> String {
        let days = (inputSeconds - inputSeconds%86400)/86400
        let hours = (inputSeconds - inputSeconds%3600)/3600-(days*24)
        let minutes = ((inputSeconds - inputSeconds%60)/60)-(hours*60)-(days*1440)
        let seconds = inputSeconds%60
        if days < 1 {
            return "\(hours) hour(s), \(minutes) minute(s), \(seconds) second(s)"
        } else {
            return "\(days) day(s), \(hours) hour(s), \(minutes) minute(s), \(seconds) second(s)"
        }
    }
}
