//
//  Notification.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/13.
//  Copyright © 2019 dks. All rights reserved.
//

import Foundation

class Notification {
    
    var id: UUID
    var datetime: Date
    var title: String
    var body: String
    var number: Int
    var range: CustomizedNotificationRange
    var event: Event?
    
    init(id: UUID, datetime: Date, title: String, body: String,
         number: Int, range: CustomizedNotificationRange) {
        self.id = id
        self.datetime = datetime
        self.title = title
        self.body = body
        self.number = number
        self.range = range
    }
}
