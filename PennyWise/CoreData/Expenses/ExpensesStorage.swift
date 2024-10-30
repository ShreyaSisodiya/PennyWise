//
//  ExpensesStorage.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import Foundation
import Combine
import CoreData

class ExpensesStorage: NSObject, ObservableObject {
    
    var expenses = CurrentValueSubject<[Expenses], Never>([])
    private let expensesFetchCotroller: NSFetchedResultsController<Expenses>
    let viewContext = PersistenceController.shared.container.viewContext
    
    static let shared: ExpensesStorage = ExpensesStorage()
    
    private override init() {
        let fetchRequest: NSFetchRequest<Expenses> = Expenses.fetchRequest()
        fetchRequest.sortDescriptors = []
        expensesFetchCotroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        expensesFetchCotroller.delegate = self
        
        do{
            try expensesFetchCotroller.performFetch()
            expenses.value = expensesFetchCotroller.fetchedObjects ?? []
        } catch{
            NSLog("Error: Could not fetch objects")
        }
    }
    
    func add(name: String, amount: String, paidBy: People, split: String, date: Date, bill: Data?, currentTrip: Trips){
        let newExpense = Expenses(context: viewContext)
        
        newExpense.name = name
        newExpense.amount = amount
        newExpense.paidBy = paidBy
        newExpense.split = split
        newExpense.date = date
        newExpense.bill = bill
        newExpense.belonsToTrip = currentTrip
        
        try? viewContext.save()
    }
}

extension ExpensesStorage: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let expenses = controller.fetchedObjects as? [Expenses] else { return }
        self.expenses.value = expenses
    }
}
