//
//  ExpensesViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import Foundation
import Combine

class ExpensesViewModel : ObservableObject{
    
    @Published var expenses : [Expenses] = []
    private var cancellable : AnyCancellable?
    
    var expensesPublisher : AnyPublisher<[Expenses], Never> = ExpensesStorage.shared.expenses.eraseToAnyPublisher()
    
    init(){
        cancellable = expensesPublisher.sink{ expenses in self.expenses = expenses }
        expenses.sort {$0.date! > $1.date!}
        
    }
}
