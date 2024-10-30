//
//  Expenses+CoreDataProperties.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//
//

import Foundation
import CoreData


extension Expenses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses> {
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }

    @NSManaged public var amount: String?
    @NSManaged public var bill: Data?
    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var split: String?
    @NSManaged public var belonsToTrip: Trips?
    @NSManaged public var paidBy: People?

}

extension Expenses : Identifiable {

}
