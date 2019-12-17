//
//  InvitationDB+CoreDataClass.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData

@objc(InvitationDB)
public class InvitationDB: NSManagedObject {
    convenience init(name: String, lastEditTime: Date, insertInto context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "InvitationDB", in: context)
        self.init(entity: entity!, insertInto: context)
        self.name = name
        self.lastEditTime = lastEditTime
    }
}
