//
//  Plan+CoreDataProperties.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

// MARK: - Plan properties

extension Plan {

    @NSManaged var additionalInfo: String?
    @NSManaged var durationDays: Int16 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var endDate: Date?
    @NSManaged var fireDate: Date?
    @NSManaged var inProgress: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var medicineKind: String?
    @NSManaged var medicineName: String?
    @NSManaged var notificationId: String?
    @NSManaged var otherUser: String?
    @NSManaged var periodicity: Int16 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var startDate: Date?
    @NSManaged var unitsPerDose: Int16 // cannot mark as optional because Objective-C compatibility issues

    @NSManaged var event: Set<Event>

}

// MARK: - Plan KVC compliant to-many accessors and helpers

extension Plan {

    @objc(addEventObject:)
    @NSManaged func addToEvent(_ value: Event)

    @objc(removeEventObject:)
    @NSManaged func removeFromEvent(_ value: Event)

    @objc(addEvent:)
    @NSManaged func addToEvent(_ values: Set<Event>)

    @objc(removeEvent:)
    @NSManaged func removeFromEvent(_ values: Set<Event>)

}

