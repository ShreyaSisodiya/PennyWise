//
//  People+CoreDataProperties.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//
//

import Foundation
import CoreData


extension People {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<People> {
        return NSFetchRequest<People>(entityName: "People")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var isOnTrips: NSSet?
    @NSManaged public var paidFor: NSSet?

}

// MARK: Generated accessors for isOnTrips
extension People {

    @objc(addIsOnTripsObject:)
    @NSManaged public func addToIsOnTrips(_ value: Trips)

    @objc(removeIsOnTripsObject:)
    @NSManaged public func removeFromIsOnTrips(_ value: Trips)

    @objc(addIsOnTrips:)
    @NSManaged public func addToIsOnTrips(_ values: NSSet)

    @objc(removeIsOnTrips:)
    @NSManaged public func removeFromIsOnTrips(_ values: NSSet)

}

// MARK: Generated accessors for paidFor
extension People {

    @objc(addPaidForObject:)
    @NSManaged public func addToPaidFor(_ value: Expenses)

    @objc(removePaidForObject:)
    @NSManaged public func removeFromPaidFor(_ value: Expenses)

    @objc(addPaidFor:)
    @NSManaged public func addToPaidFor(_ values: NSSet)

    @objc(removePaidFor:)
    @NSManaged public func removeFromPaidFor(_ values: NSSet)

}

extension People : Identifiable {

}
