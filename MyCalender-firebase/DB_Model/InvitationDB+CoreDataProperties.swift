//
//  InvitationDB+CoreDataProperties.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


extension InvitationDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvitationDB> {
        return NSFetchRequest<InvitationDB>(entityName: "InvitationDB")
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var lastEditTime: Date?
    @NSManaged public var task: TaskDB?

}
