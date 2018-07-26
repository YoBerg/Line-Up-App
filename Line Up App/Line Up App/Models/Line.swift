//
//  Lines.Swift
//  Line Up App
//
//  Created by Macbook on 7/25/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import Foundation

class Line {
    
    var name: String
    var waitTime: Int
    var members: Array<String>
    var maxMembers: Int
    var creator: String
    
    init(name: String, waitTime: Int, members: Array<String>, maxMembers: Int, creator: String) {
        self.name = name
        self.waitTime = waitTime
        self.members = members
        self.maxMembers = maxMembers
        self.creator = creator
    }
    
}