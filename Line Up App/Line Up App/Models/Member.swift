//
//  Member.swift
//  Line Up App
//
//  Created by Macbook on 7/30/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import Foundation

class Member {
    
    var username: String
    let uid: String
    var spot: Int
    
    init(uid: String, spot: Int) {
        self.uid = uid
        self.spot = spot
        self.username = ""
    }
    
}
