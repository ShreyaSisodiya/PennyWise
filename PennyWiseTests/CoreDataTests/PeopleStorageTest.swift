//
//  PeopleStorageTest.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/7/24.
//

import Foundation
import Combine
import CoreData
import PennyWise

class PeopleStorageTest : NSObject, ObservableObject {
    
    var people = CurrentValueSubject<[People], Never>([])
    private let peopleFetchController: NSFetchedResultsController<People>
    let viewContext = PersistenceTestController.shared.container.viewContext
    
    static let shared: PeopleStorageTest = PeopleStorageTest()
    
    var entityDescription: NSEntityDescription!
    
    private override init() {
        
        let fetchRequest: NSFetchRequest<People> = People.fetchRequest()
        fetchRequest.sortDescriptors = []
        peopleFetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        peopleFetchController.delegate = self
        
        do {
            try peopleFetchController.performFetch()
            people.value = peopleFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: Could not fetch objects")
        }
        
        entityDescription = NSEntityDescription.entity(forEntityName: "People", in: viewContext)!
    }
    
    func add(name: String, email: String) {
        let newPerson = People(entity: entityDescription, insertInto: viewContext)
        newPerson.name = name
        newPerson.email = email
        try? viewContext.save()
    }
    
    func doesPersonExist(withEmail email: String) -> Bool {
        return people.value.contains { $0.wrappedEmail.lowercased() == email.lowercased() }
    }
    
    func doesPersonExist(withName name: String) -> Bool {
        return people.value.contains { $0.wrappedName.lowercased() == name.lowercased() }
    }
}

extension PeopleStorageTest: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let people = controller.fetchedObjects as? [People] else { return }
        self.people.value = people
    }
}
