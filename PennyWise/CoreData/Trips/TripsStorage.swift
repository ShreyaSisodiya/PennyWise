//
//  TripsStorage.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import Foundation
import Combine
import CoreData

class TripsStorage: NSObject, ObservableObject {
    
    var trips = CurrentValueSubject<[Trips], Never>([])
    private let tripsFetchController: NSFetchedResultsController<Trips>
    let viewContext = PersistenceController.shared.container.viewContext
    
    static let shared: TripsStorage = TripsStorage()
    
    private override init() {
        let fetchRequest: NSFetchRequest<Trips> = Trips.fetchRequest()
        fetchRequest.sortDescriptors = []
        tripsFetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        tripsFetchController.delegate = self
        
        do{
            try tripsFetchController.performFetch()
            trips.value = tripsFetchController.fetchedObjects ?? []
        } catch{
            NSLog("Error: Could not fetch objects")
        }
    }
    
//    func add(tripName: String, tripDuration: String, peopleNames: [String], peopleEmails: [String]) {
//        
//        let newTrip = Trips(context: viewContext)
//        newTrip.name = tripName
//        newTrip.duration = tripDuration
//        
//        var peopleArray = [People]()
//        
//        for item in 0..<peopleNames.count {
//            if !PeopleStorage.shared.doesPersonExist(withEmail: peopleEmails[item]) {
//                let person = People(context: viewContext)
//                person.name = peopleNames[item]
//                person.email = peopleEmails[item]
//                peopleArray.append(person)
//            } else {
//                print("Person with email \(peopleEmails[item]) already exists and won't be added.")
//            }
//        }
//        
//        newTrip.addToHasPeople(NSSet(array: peopleArray))
//        try? viewContext.save()
//    }
    
    func add(tripName: String, tripDuration: String, peopleNames: [String], peopleEmails: [String]) {
        
        let newTrip = Trips(context: viewContext)
        newTrip.name = tripName
        newTrip.duration = tripDuration
        
        var peopleArray = [People]()
        
        for (index, email) in peopleEmails.enumerated() {
            if let existingPerson = PeopleStorage.shared.people.value.first(where: { $0.wrappedEmail.lowercased() == email.lowercased() }) {
                // If person exists, link them to the trip
                peopleArray.append(existingPerson)
            } else {
                // Otherwise, create a new person and link to the trip
                let newPerson = People(context: viewContext)
                newPerson.name = peopleNames[index]
                newPerson.email = email
                peopleArray.append(newPerson)
            }
        }
        
        newTrip.addToHasPeople(NSSet(array: peopleArray))
        
        do {
            try viewContext.save()
            print("New trip and people saved successfully.")
        } catch {
            print("Failed to save trip: \(error)")
        }
    }
    

//    func addPeopleToTrip(currentTrip: Trips, peopleNames: [String], peopleEmails: [String]) {
//        var peopleArray = [People]()
//        
//        for item in 0..<peopleNames.count {
//            if !PeopleStorage.shared.doesPersonExist(withEmail: peopleEmails[item]) {
//                let person = People(context: viewContext)
//                person.name = peopleNames[item]
//                person.email = peopleEmails[item]
//                peopleArray.append(person)
//            } else {
//                print("Person with email \(peopleEmails[item]) already exists and won't be added.")
//            }
//        }
//        
//        currentTrip.addToHasPeople(NSSet(array: peopleArray))
//        try? viewContext.save()
//    }
    
    func addPeopleToTrip(currentTrip: Trips, peopleNames: [String], peopleEmails: [String]) {
        var peopleArray = [People]()

        for item in 0..<peopleNames.count {
            // Check if person already exists in PeopleStorage
            if let existingPerson = PeopleStorage.shared.people.value.first(where: { $0.wrappedEmail.lowercased() == peopleEmails[item].lowercased() }) {
                // If the person exists, add them to the array for linking
                peopleArray.append(existingPerson)
            } else {
                // Otherwise, create a new person and add to the array
                let newPerson = People(context: viewContext)
                newPerson.name = peopleNames[item]
                newPerson.email = peopleEmails[item]
                peopleArray.append(newPerson)
            }
        }
        
        // Add all people (existing and new) to the trip
        currentTrip.addToHasPeople(NSSet(array: peopleArray))
        
        do {
            // Save changes to persist the additions
            try viewContext.save()
            print("People added to trip: \(peopleNames)")
        } catch {
            print("Error saving people to trip: \(error)")
        }
    }

}

extension TripsStorage: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let trips = controller.fetchedObjects as? [Trips] else { return }
        self.trips.value = trips
    }
}

extension TripsStorage {
    func doesTripExist(withName name: String) -> Bool {
        let fetchRequest: NSFetchRequest<Trips> = Trips.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let existingTrips = try viewContext.fetch(fetchRequest)
            print("Existing trips with the name \(name): \(existingTrips.count)")
            return !existingTrips.isEmpty
        } catch {
            NSLog("Error checking for duplicate trip names: \(error)")
            return false
        }
    }
}
