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
            
            // Add debug logging to check for duplicates
            let uniqueEmails = Set(people.value.map { $0.wrappedEmail })
            print("Unique emails count: \(uniqueEmails.count), Total people count: \(people.value.count)")
            
            // Log individual entries
            people.value.forEach { person in
                print("Loaded person: \(person.wrappedName) with email: \(person.wrappedEmail)")
            }

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
//    func doesPersonExist(withEmail email: String) -> Bool {
//        // Directly check the stored people array for any matching email
//        let lowercasedEmail = email.lowercased()
//        return people.value.contains { $0.wrappedEmail.lowercased() == lowercasedEmail }
//    }
    
    func doesPersonExist(withEmail email: String) -> Bool {
        let lowercasedEmail = email.lowercased()
        NSLog("Checking existence for email: \(lowercasedEmail)")
        
        // Log all emails in the array to ensure they are as expected
        people.value.forEach { person in
            NSLog("Stored email: \(person.wrappedEmail.lowercased())")
        }
        
        let result = people.value.contains { $0.wrappedEmail.lowercased() == lowercasedEmail }
        NSLog("Email exists: \(result)")
        return result
    }
    
    func doesPersonExist(withName name: String) -> Bool {
        // Directly check the stored people array for any matching name
        let lowercasedName = name.lowercased()
        return people.value.contains { $0.wrappedName.lowercased() == lowercasedName }
    }
}


extension PeopleStorage {
    func addPersonIfNotExists(name: String, email: String) {
        // Check if the person already exists by name or email
        if !doesPersonExist(withEmail: email) && !doesPersonExist(withName: name) {
            // Add new person logic here (e.g., creating and saving a new People object)
            let newPerson = People(context: viewContext)
            newPerson.name = name
            newPerson.email = email

            do {
                try viewContext.save()
                //print("New person added: \(name) with email: \(email)")
                print("New person added with full email: \(newPerson.email ?? "No Email")")
            } catch {
                print("Failed to add new person: \(error)")
            }
        } else {
            print("Person already exists and will not be added again.")
        }
    }
}



