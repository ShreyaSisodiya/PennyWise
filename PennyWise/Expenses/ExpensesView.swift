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
    @EnvironmentObject var currencyManager: CurrencyManager
    
    var body: some View {
        List{
            ForEach(expensesViewModel.expenses, id : \.self){expense in
                if expense.belongsToTrip == currentTrip{
                    NavigationLink(destination : ExpensesInfoView(currentExpense: expense, expensesInfoViewModel: ExpensesInfoViewModel(currentExpense: expense))){
                        Section{
                            VStack(alignment: .leading, spacing: 10){
                                Text(expense.name!)
                                
                                
                                // Convert and format amount based on selected currency
                                if let amount = Double(expense.amount!) {
                                    let convertedAmount = currencyManager.selectedCurrency == "USD" ? amount : currencyManager.convertUSDtoEuro(amount)
                                    let formattedAmount = currencyManager.formatAmount(convertedAmount, currency: currencyManager.selectedCurrency)
                                    
                                    let subtitle = "\(expense.paidBy!.wrappedName) paid: \(formattedAmount)"
                                    Text(subtitle).font(.subheadline).foregroundColor(.gray)
                                    
                                }
                                
                            }.frame(height : 75)
                        }
                    }
                }
            }
        }
        .navigationTitle(expensesNavigationTitle)
        .toolbar{
            NavigationLink(destination : AddExpensesView(currentTrip: currentTrip, addExpensesViewModel: AddExpensesViewModel(currentTrip: currentTrip, currencyManager: currencyManager))){
                Image(systemName: plusImage).imageScale(.large)
            }
        }
    }
}
