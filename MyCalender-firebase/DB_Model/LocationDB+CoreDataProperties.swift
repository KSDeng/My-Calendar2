//
//  LocationDB+CoreDataProperties.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


extension LocationDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationDB> {
        return NSFetchRequest<LocationDB>(entityName: "LocationDB")
    }

    @NSManaged public var title: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var detail: String?
    @NSManaged public var task: TaskDB?

}
