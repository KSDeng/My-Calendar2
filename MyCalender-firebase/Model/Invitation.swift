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
    var phoneNumber: String
    var lastEditTime: Date
    var task: Task?
    
    init(name: String, phoneNumber: String, lastEditTime: Date) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.lastEditTime = lastEditTime
    }
}
