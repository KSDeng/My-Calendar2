//
//  Invitation.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/13.
//  Copyright © 2019 dks. All rights reserved.
//

import Foundation

class Invitation {
    var name: String
    var contact: String?
    var lastEditTime: Date
    
    init(name: String, lastEditTime: Date) {
        self.name = name
        self.lastEditTime = lastEditTime
    }
}
