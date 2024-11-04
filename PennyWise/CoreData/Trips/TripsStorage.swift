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
    
    func add(tripName: String, tripDuration: String, peopleNames: [String], peopleEmails: [String]) {
        
        let newTrip = Trips(context: viewContext)
        newTrip.name = tripName
        newTrip.duration = tripDuration
        
        var peopleArray = [People]()
        
        for item in 0..<peopleNames.count {
            let person = People(context: viewContext)
            person.name = peopleNames[item]
            person.email = peopleNames[item]
            peopleArray.append(person)
        }
        
        newTrip.addToHasPeople(NSSet(array: peopleArray))
        
        try? viewContext.save()
    }
    
    func addPeopleToTrip(currentTrip: Trips, peopleNames: [String], peopleEmails: [String]){
        
        var peopleArray = [People]()
        
        for item in 0..<peopleNames.count {
            let person = People(context: viewContext)
            person.name = peopleNames[item]
            person.email = peopleNames[item]
            peopleArray.append(person)
        }
        
        currentTrip.addToHasPeople(NSSet(array: peopleArray))
        
        try? viewContext.save()
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
