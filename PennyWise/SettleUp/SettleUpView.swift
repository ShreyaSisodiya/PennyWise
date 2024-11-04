//
//  SettleUpView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import SwiftUI

struct SettleUpView: View {
    
    @StateObject private var settleUpViewModel : SettleUpViewModel
    
    init(settleUpViewModel : SettleUpViewModel){
        self._settleUpViewModel = StateObject(wrappedValue: settleUpViewModel)
    }
    
    var body: some View {
        Form{
            ForEach(settleUpViewModel.finalSettlements.keys.sorted(), id : \.self){key in
                Section(header : Text(key)){
                    let dictionary = settleUpViewModel.finalSettlements[key]
                    if !dictionary!.isEmpty{
                        ForEach((dictionary?.keys.sorted())!, id : \.self){ key2 in
                            let amountOwed = dictionary?[key2]?.reduce(0, +)
                            Text("\(owes) \(key2) \(String(format: doubleFormat, amountOwed!))\(dollar)")
                        }
                    }
                    else{
                        Text(owesNothingText)
                    }
                }
            }
        }
        Button(action: {settleUpViewModel.showMailView.toggle()}){
            RoundedRectangle(cornerRadius: buttonCornerRadius)
                .frame(height : buttonFrameHeight)
                .overlay(Text(remindPeopleButtonText).foregroundColor(.white))
        }.padding()
            .disabled(!MailView.canSendMail)
            .sheet(isPresented: $settleUpViewModel.showMailView) {
                MailView(data: $settleUpViewModel.mailData){_ in }
            }
            .navigationTitle(settleUpNavigationTitle)
    }
}
