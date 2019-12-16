//
//  TaskDB+CoreDataProperties.swift
//  MyCalender-firebase
//
//  Created by DKS_mac on 2019/12/15.
//  Copyright © 2019 dks. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskDB> {
        return NSFetchRequest<TaskDB>(entityName: "TaskDB")
    }

    @NSManaged public var startDate: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var typeRawValue: String?
    @NSManaged public var ifAllDay: Bool
    @NSManaged public var timeLengthInDays: Int16
    @NSManaged public var title: String?
    @NSManaged public var colorPoint: Int16
    @NSManaged public var note: String?
    @NSManaged public var location: LocationDB?
    @NSManaged public var notifications: NSSet?
    @NSManaged public var invitations: NSSet?

}

// MARK: Generated accessors for notifications
extension TaskDB {

    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: NotificationDB)

    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: NotificationDB)

    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSSet)

    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSSet)

}

// MARK: Generated accessors for invitations
extension TaskDB {

    @objc(addInvitationsObject:)
    @NSManaged public func addToInvitations(_ value: InvitationDB)

    @objc(removeInvitationsObject:)
    @NSManaged public func removeFromInvitations(_ value: InvitationDB)

    @objc(addInvitations:)
    @NSManaged public func addToInvitations(_ values: NSSet)

    @objc(removeInvitations:)
    @NSManaged public func removeFromInvitations(_ values: NSSet)

}
