//
//  ExpensesView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import SwiftUI


struct ExpensesView: View {
    
    @StateObject private var expensesViewModel = ExpensesViewModel()
    let currentTrip : Trips
    
    var body: some View {
        List{
            ForEach(expensesViewModel.expenses, id : \.self){expense in
                if expense.belongsToTrip == currentTrip{
                    NavigationLink(destination : ExpensesInfoView(currentExpense: expense, expensesInfoViewModel: ExpensesInfoViewModel(currentExpense: expense))){
                        Section{
                            VStack(alignment: .leading, spacing: 10){
                                Text(expense.name!)
                                let subtitle : String = expense.paidBy!.wrappedName + paid + expense.amount! + dollar
                                Text(subtitle).font(.subheadline).foregroundColor(.gray)
                            }.frame(height : 75)
                        }
                    }
                }
            }
        }
        .navigationTitle(expensesNavigationTitle)
        .toolbar{
            NavigationLink(destination : AddExpensesView(currentTrip: currentTrip, addExpensesViewModel: AddExpensesViewModel(currentTrip: currentTrip))){
                Image(systemName: plusImage).imageScale(.large)
            }
        }
    }
}
