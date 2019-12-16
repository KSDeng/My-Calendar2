//
//  NotificationDB+CoreDataProperties.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


extension NotificationDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationDB> {
        return NSFetchRequest<NotificationDB>(entityName: "NotificationDB")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var datetime: Date?
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var rangeRawValue: String?
    @NSManaged public var number: Int16
    @NSManaged public var task: TaskDB?

}
