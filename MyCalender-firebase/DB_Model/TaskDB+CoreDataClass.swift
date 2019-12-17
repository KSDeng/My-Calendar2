//
//  TaskDB+CoreDataClass.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/16.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TaskDB)
public class TaskDB: NSManagedObject {
    
    // https://stackoverflow.com/questions/26428366/how-to-make-a-designated-initializer-for-nsmanagedobject-subclass-in-swift
    convenience init(startDate: Date, ifAllDay: Bool, timeLengthInDays: Int, title: String, colorPoint: Int, insertInto context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "TaskDB", in: context)

        self.init(entity: entity!, insertInto: context)

        self.startDate = startDate

        self.ifAllDay = ifAllDay

        self.timeLengthInDays = Int16(timeLengthInDays)

        self.title = title

        self.typeRawValue = EventType.Task.rawValue
        
        self.colorPoint = Int16(colorPoint)

      }
}
