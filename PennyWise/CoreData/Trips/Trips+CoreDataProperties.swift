//
//  Trips+CoreDataProperties.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//
//

import Foundation
import CoreData


extension Trips {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trips> {
        return NSFetchRequest<Trips>(entityName: "Trips")
    }

    @NSManaged public var duration: String?
    @NSManaged public var name: String?
    @NSManaged public var hasExpenses: NSSet?
    @NSManaged public var hasPeople: NSSet?

}

// MARK: Generated accessors for hasExpenses
extension Trips {

    @objc(addHasExpensesObject:)
    @NSManaged public func addToHasExpenses(_ value: Expenses)

    @objc(removeHasExpensesObject:)
    @NSManaged public func removeFromHasExpenses(_ value: Expenses)

    @objc(addHasExpenses:)
    @NSManaged public func addToHasExpenses(_ values: NSSet)

    @objc(removeHasExpenses:)
    @NSManaged public func removeFromHasExpenses(_ values: NSSet)

}

// MARK: Generated accessors for hasPeople
extension Trips {

    @objc(addHasPeopleObject:)
    @NSManaged public func addToHasPeople(_ value: People)

    @objc(removeHasPeopleObject:)
    @NSManaged public func removeFromHasPeople(_ value: People)

    @objc(addHasPeople:)
    @NSManaged public func addToHasPeople(_ values: NSSet)

    @objc(removeHasPeople:)
    @NSManaged public func removeFromHasPeople(_ values: NSSet)

}

extension Trips : Identifiable {

}
