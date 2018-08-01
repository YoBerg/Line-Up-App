//
//  UIViewControllerExtensions.swift
//  Line Up App
//
//  Created by Macbook on 7/26/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func isNsnullOrNil(_ object : Any?) -> Bool {
        if let _: Any = object {
            return true
        } else { return false }
    }
}
