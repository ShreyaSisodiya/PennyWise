//
//  SettleUpView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import SwiftUI

struct SettleUpView: View {
    
    @StateObject private var settleUpViewModel: SettleUpViewModel
    @EnvironmentObject var currencyManager: CurrencyManager
    
    init(settleUpViewModel: SettleUpViewModel) {
        self._settleUpViewModel = StateObject(wrappedValue: settleUpViewModel)
    }
    
    var body: some View {
        Form {
            ForEach(settleUpViewModel.finalSettlements.keys.sorted(), id: \.self) { key in
                Section(header: Text(key)) {
                    displaySettlementDetails(for: key)
                }
            }
            
            Button(action: { settleUpViewModel.showMailView.toggle() }) {
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .frame(height: buttonFrameHeight)
                    .overlay(Text(remindPeopleButtonText).foregroundColor(.white))
            }
            .padding()
            .disabled(!MailView.canSendMail)
            .sheet(isPresented: $settleUpViewModel.showMailView) {
                MailView(data: $settleUpViewModel.mailData) { _ in }
            }
        }
        .navigationTitle(settleUpNavigationTitle)
    }
    
    private func displaySettlementDetails(for key: String) -> some View {
        if let dictionary = settleUpViewModel.finalSettlements[key], !dictionary.isEmpty {
            return AnyView(
                ForEach(dictionary.keys.sorted(), id: \.self) { key2 in
                    if let amounts = dictionary[key2] {
                        let amountOwed = amounts.reduce(0, +)
                        let currencySymbol = currencyManager.selectedCurrency == "USD" ? "$" : "€"
                        let displayText = "\(owes) \(key2) \(currencySymbol)\(String(format: doubleFormat, amountOwed))"
                        Text(displayText)
                    }
                }
            )
        } else {
            return AnyView(Text(owesNothingText))
        }
    }
}


