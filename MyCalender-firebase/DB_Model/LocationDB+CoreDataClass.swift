//
//  LocationDB+CoreDataClass.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LocationDB)
public class LocationDB: NSManagedObject {
    convenience init(title: String, latitude: Double, longitude: Double, insertInto context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "LocationDB", in: context)
        self.init(entity: entity!, insertInto: context)
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        
    }
}
