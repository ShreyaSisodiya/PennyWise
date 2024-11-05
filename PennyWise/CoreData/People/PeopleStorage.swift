//
//  PeopleStorage.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import Foundation
import Combine
import CoreData

class PeopleStorage: NSObject, ObservableObject {
    
    var people = CurrentValueSubject<[People], Never>([])
    private let peopleFetchCotroller: NSFetchedResultsController<People>
    let viewContext = PersistenceController.shared.container.viewContext
    
    static let shared: PeopleStorage = PeopleStorage()
    
    private override init() {
        let fetchRequest: NSFetchRequest<People> = People.fetchRequest()
        fetchRequest.sortDescriptors = []
        peopleFetchCotroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        peopleFetchCotroller.delegate = self
        
        do{
            try peopleFetchCotroller.performFetch()
            people.value = peopleFetchCotroller.fetchedObjects ?? []
        } catch{
            NSLog("Error: Could not fetch objects")
        }
    }
}

extension PeopleStorage: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let people = controller.fetchedObjects as? [People] else { return }
        self.people.value = people
    }
}

extension PeopleStorage {
    func doesPersonExist(withEmail email: String) -> Bool {
        let fetchRequest: NSFetchRequest<People> = People.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email ==[c] %@", email) // Case-insensitive check

        do {
            let existingPeople = try viewContext.fetch(fetchRequest)
            return !existingPeople.isEmpty
        } catch {
            NSLog("Error checking for duplicate person emails: \(error)")
            return false
        }
    }
}

