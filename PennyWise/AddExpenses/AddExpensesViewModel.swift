//
//  AddExpensesViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import Foundation
import Combine
import UIKit

class AddExpensesViewModel : ObservableObject{
    
    @Published var people : [People] = []
    @Published var peopleInTrip : [People] = []
    private var cancellable : AnyCancellable?
    var peoplePublisher : AnyPublisher<[People], Never> = PeopleStorage.shared.people.eraseToAnyPublisher()
    var currentTrip : Trips?
    @Published var selectedImage: UIImage?
    @Published var isImagePickerDisplay : Bool = false
    
    @Published var expenseName : String = ""
    @Published var expenseCost : String = ""
    @Published var expensePaidBy : People = People()
    @Published var customSplitEnabled : Bool = false
    @Published var splitAmounts = [String]()
    @Published var expenseBill : Data? = nil
    
    private var cancellables = Set<AnyCancellable>()
    @Published var inlineErrorForExpenseName : String = ""
    @Published var inlineErrorForExpenseAmount : String = ""
    @Published var inlineErrorForSplitAmounts : String = ""
    @Published var isValid : Bool = false
    
    private var isExpenseNameEmptyPublisher : AnyPublisher<Bool, Never>{
        $expenseName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isExpenseAmountEmptyPublisher : AnyPublisher<Bool, Never>{
        $expenseCost
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isExpenseAmountCorrectPublisher : AnyPublisher<Bool, Never>{
        $expenseCost
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {if let _ = Double($0) { return true }
                else { return false }
            }
            .eraseToAnyPublisher()
    }
    
    private var isExpenseAmountValidPublisher : AnyPublisher<ExpenseAmountStatus, Never>{
        Publishers.CombineLatest(isExpenseAmountEmptyPublisher, isExpenseAmountCorrectPublisher)
            .map { if $0 { return ExpenseAmountStatus.empty }
                if !$1 { return ExpenseAmountStatus.notCorrect }
                return ExpenseAmountStatus.valid
            }
            .eraseToAnyPublisher()
    }

    
    private var areSplitsVaildPublisher : AnyPublisher<Bool, Never>{
        $splitAmounts
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { if ($0.last == "" || self.expenseCost == "" || self.customSplitEnabled == false) {return true} else {return $0.compactMap(Double.init).reduce(0, +) == Double(self.expenseCost)!}}
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher : AnyPublisher<Bool, Never>{
        Publishers.CombineLatest3(isExpenseNameEmptyPublisher, isExpenseAmountValidPublisher, areSplitsVaildPublisher)
            .map{
                !$0 && $1 == .valid && $2
            }
            .eraseToAnyPublisher()
    }
    
    
    
    init(currentTrip : Trips){
        self.currentTrip = currentTrip
        cancellable = peoplePublisher.sink{ people in
            self.people = people
            DispatchQueue.main.async {
                self.expensePaidBy = self.people[0]
            }
        }
        for person in people {
            if person.tripArray.contains(currentTrip){
                peopleInTrip.append(person)
                splitAmounts.append("")
            }
        }
        
        isExpenseNameEmptyPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { status in
                if status {return expenseNameErrorText}
                else {return ""}
            }
            .assign(to: \.inlineErrorForExpenseName, on: self)
            .store(in: &cancellables)
        
        isExpenseAmountValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { status in
                switch status{
                case .empty : return expenseAmountEmptyErrorText
                case .notCorrect : return expenseAmountNotCorrectErrorText
                case .valid : return ""
                }
            }
            .assign(to: \.inlineErrorForExpenseAmount, on: self)
            .store(in: &cancellables)
        
        areSplitsVaildPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { status in
                if !status {return splitErrorText}
                else {return ""}
            }
            .assign(to: \.inlineErrorForSplitAmounts, on: self)
            .store(in: &cancellables)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }
    
    func addExpense(){
        if customSplitEnabled == false{
            let amount = Double(expenseCost)!
            for item in 0 ..< splitAmounts.count{
                splitAmounts[item] = String(amount / Double(splitAmounts.count))
            }
        }
        else{
            expenseBill = selectedImage?.jpegData(compressionQuality: 1.0)
        }
        let split = splitAmounts.joined(separator: ";")
        ExpensesStorage.shared.add(name: expenseName, amount: expenseCost, paidBy: expensePaidBy, split: split, date: Date.now, bill: expenseBill, currentTrip: currentTrip!)
    }
}
