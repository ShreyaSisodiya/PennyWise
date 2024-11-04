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
    
    init(currentExpense : Expenses, expensesInfoViewModel : ExpensesInfoViewModel){
        self.currentExpense = currentExpense
        self._expensesInfoViewModel = StateObject(wrappedValue: expensesInfoViewModel)
    }
    
    var body: some View {
        Form{
            Section(header : Text(paidByText)){
                Text(expensesInfoViewModel.currentExpense.paidBy!.wrappedName)
            }
            Section(header : Text(expenseAmountHeader)){
                Text("\(expensesInfoViewModel.currentExpense.amount!)\(dollar)")
            }
            Section(header : Text(date)){
                Text(expensesInfoViewModel.dateFormatter.string(from: currentExpense.date!))
            }
            Section(header : Text(sharesHeader)){
                ForEach(0 ..< expensesInfoViewModel.peopleInTrip.count, id : \.self){item in
                    Text("\(expensesInfoViewModel.peopleInTrip[item].wrappedName)\(aphostropheS) \(share) \(expensesInfoViewModel.split[item])\(dollar)")
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

