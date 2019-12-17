//
//  NotificationDB+CoreDataClass.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/16.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NotificationDB)
public class NotificationDB: NSManagedObject {

    convenience init(id: UUID, datetime: Date, title: String, body: String, number: Int, range: CustomizedNotificationRange, insertInto context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "NotificationDB", in: context)

        self.init(entity: entity!, insertInto: context)
        
        self.id = id
        
        self.datetime = datetime
        
        self.title = title
        
        self.body = body
        
        self.number = Int16(number)
        
        self.rangeRawValue = range.rawValue
    }
}
