//
//  TaskDB+CoreDataClass.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


// https://stackoverflow.com/questions/26428366/how-to-make-a-designated-initializer-for-nsmanagedobject-subclass-in-swift
@objc(TaskDB)
public class TaskDB: NSManagedObject {

    convenience init(startDate: Date, ifAllDay: Bool, timeLengthInDays: Int, title: String, insertInto context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "TaskDB", in: context)
        self.init(entity: entity!, insertInto: context)
        // self.init(context: context)
        self.startDate = startDate
        self.ifAllDay = ifAllDay
        self.timeLengthInDays = Int16(timeLengthInDays)
        self.title = title
        self.typeRawValue = EventType.Task.rawValue
        print(self)
    }
}
