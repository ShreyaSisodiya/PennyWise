//
//  ExpensesStorageTest.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/7/24.
//

import Foundation
import CoreData
import Combine
import PennyWise


class ExpensesStorageTest : NSObject, ObservableObject{
    
    var expenses = CurrentValueSubject<[Expenses], Never>([])
    private let expensesFetchController : NSFetchedResultsController<Expenses>
    let viewContext = PersistenceTestController.shared.container.viewContext
    
    static let shared : ExpensesStorageTest = ExpensesStorageTest()
    
    var entityDescription: NSEntityDescription!
    
    private override init() {
        
        let fetchRequest: NSFetchRequest<Expenses> = Expenses.fetchRequest()
        fetchRequest.sortDescriptors = []
        expensesFetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        expensesFetchController.delegate = self
        
        do{
            try expensesFetchController.performFetch()
            expenses.value = expensesFetchController.fetchedObjects ?? []
        }
        catch{
            NSLog("Error : Could Not Fetch Objects")
        }
        
        entityDescription  = NSEntityDescription.entity(forEntityName: "Expenses", in: viewContext)!
    }
    
    func add(name : String, amount : String, paidBy : People, currentTrip : Trips){
        
        let newExpense = Expenses(entity: entityDescription, insertInto: viewContext)
        newExpense.name = name
        newExpense.amount = amount
        newExpense.paidBy = paidBy
        newExpense.belongsToTrip = currentTrip
        
        try? viewContext.save()
    }
}

extension ExpensesStorageTest : NSFetchedResultsControllerDelegate{
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let expenses = controller.fetchedObjects as? [Expenses] else { return }
        self.expenses.value = expenses
    }
}
