//
//  ExpensesInfoView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import SwiftUI


struct ExpensesInfoView: View {
    
    @StateObject private var expensesInfoViewModel : ExpensesInfoViewModel
    let currentExpense : Expenses
    @EnvironmentObject var currencyManager: CurrencyManager
    
    init(currentExpense : Expenses, expensesInfoViewModel : ExpensesInfoViewModel){
        self.currentExpense = currentExpense
        self._expensesInfoViewModel = StateObject(wrappedValue: expensesInfoViewModel)
    }
    
    var body: some View {
        Form{
            Section(header : Text(paidByText)){
                Text(expensesInfoViewModel.currentExpense.paidBy!.wrappedName)
            }
            
            
//            Section(header : Text(expenseAmountHeader)){
//                let currencySymbol = currencyManager.selectedCurrency == "USD" ? "$" : "€"
//                Text("\(currencySymbol)\(expensesInfoViewModel.currentExpense.amount!)")
//            }
            
            Section(header: Text(expenseAmountHeader)) {
                if let amount = Double(expensesInfoViewModel.currentExpense.amount!) {
                    let convertedAmount = currencyManager.selectedCurrency == "USD" ? amount : currencyManager.convertUSDtoEuro(amount)
                    let formattedAmount = currencyManager.formatAmount(convertedAmount, currency: currencyManager.selectedCurrency)
                    Text(formattedAmount)
                }
            }
            
            Section(header : Text(date)){
                Text(expensesInfoViewModel.dateFormatter.string(from: currentExpense.date!))
            }
            
            
//            Section(header : Text(sharesHeader)){
//                ForEach(0 ..< expensesInfoViewModel.peopleInTrip.count, id : \.self){item in
//                    let currencySymbol = currencyManager.selectedCurrency == "USD" ? "$" : "€"
//                    
//                    // Ensure `split` array has a valid element at `item` index
//                    if item < expensesInfoViewModel.split.count {
//                        Text("\(expensesInfoViewModel.peopleInTrip[item].wrappedName)\(aphostropheS) \(share) \(currencySymbol)\(expensesInfoViewModel.split[item])")
//                    } else {
//                        Text("\(expensesInfoViewModel.peopleInTrip[item].wrappedName)\(aphostropheS) \(share) \(currencySymbol)0.00")
//                    }
//                }
//            }
            
            Section(header: Text(sharesHeader)) {
                ForEach(0 ..< expensesInfoViewModel.peopleInTrip.count, id: \.self) { item in
                    if item < expensesInfoViewModel.split.count, let splitAmount = Double(expensesInfoViewModel.split[item]) {
                        let convertedSplitAmount = currencyManager.selectedCurrency == "USD" ? splitAmount : currencyManager.convertUSDtoEuro(splitAmount)
                        let formattedSplitAmount = currencyManager.formatAmount(convertedSplitAmount, currency: currencyManager.selectedCurrency)
                        Text("\(expensesInfoViewModel.peopleInTrip[item].wrappedName)\(aphostropheS) \(share): \(formattedSplitAmount)")
                    } else {
                        // Fallback for any missing values in `split`
                        let zeroAmount = currencyManager.formatAmount(0.0, currency: currencyManager.selectedCurrency)
                        Text("\(expensesInfoViewModel.peopleInTrip[item].wrappedName)\(aphostropheS) \(share): \(zeroAmount)")
                    }
                }
            }
            
            
            Section(header : Text(receiptText)){
                if let billImage = expensesInfoViewModel.billImage{
                    Image(uiImage: billImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: imageWidth, height: imageHeight, alignment: .center)
                }
            }
        }
        .navigationTitle(expensesInfoViewModel.currentExpense.name!)
    }
}

