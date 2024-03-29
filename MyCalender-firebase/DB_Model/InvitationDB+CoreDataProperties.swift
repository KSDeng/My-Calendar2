//
//  InvitationDB+CoreDataProperties.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/17.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


extension InvitationDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvitationDB> {
        return NSFetchRequest<InvitationDB>(entityName: "InvitationDB")
    }

    @NSManaged public var lastEditTime: Date
    @NSManaged public var name: String
    @NSManaged public var contact: String?
    @NSManaged public var task: TaskDB?

}
