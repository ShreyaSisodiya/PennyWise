//
//  TripsStorageTest.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/7/24.
//

import Foundation
import CoreData
import Combine
import PennyWise

class TripsStorageTest: NSObject, ObservableObject {
    
    var trips = CurrentValueSubject<[Trips], Never>([])
    private let tripsFetchController: NSFetchedResultsController<Trips>
    let viewContext = PersistenceTestController.shared.container.viewContext
    
    static let shared: TripsStorageTest = TripsStorageTest()
    
    var tripEntityDescription: NSEntityDescription!
    var peopleEntityDescription: NSEntityDescription!
    
    private override init() {
        
        let fetchRequest: NSFetchRequest<Trips> = Trips.fetchRequest()
        fetchRequest.sortDescriptors = []
        tripsFetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        tripsFetchController.delegate = self
        
        do {
            try tripsFetchController.performFetch()
            trips.value = tripsFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: Could not fetch objects")
        }
        
        tripEntityDescription = NSEntityDescription.entity(forEntityName: "Trips", in: viewContext)!
        peopleEntityDescription = NSEntityDescription.entity(forEntityName: "People", in: viewContext)!
    }
    
    func add(tripName: String) {
        let newTrip = Trips(entity: tripEntityDescription, insertInto: viewContext)
        newTrip.name = tripName
        try? viewContext.save()
    }
    
    func addPeopleToTrip(currentTrip: Trips, peopleNames: [String], peopleEmails: [String]) {
        
        var peopleArray = [People]()
        
        for (index, name) in peopleNames.enumerated() {
            let person = People(entity: peopleEntityDescription, insertInto: viewContext)
            person.name = name
            person.email = peopleEmails[index]
            peopleArray.append(person)
        }
        
        currentTrip.addToHasPeople(NSSet(array: peopleArray))
        try? viewContext.save()
    }
}

extension TripsStorageTest: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let trips = controller.fetchedObjects as? [Trips] else { return }
        self.trips.value = trips
    }
}
