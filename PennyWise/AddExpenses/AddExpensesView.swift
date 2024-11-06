//
//  AddExpensesView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import SwiftUI

struct AddExpensesView: View {
    
    let currentTrip : Trips
    @StateObject private var addExpensesViewModel : AddExpensesViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var currencyManager: CurrencyManager
    
    
    init(currentTrip : Trips, addExpensesViewModel : AddExpensesViewModel){
        self.currentTrip = currentTrip
        self._addExpensesViewModel = StateObject(wrappedValue: addExpensesViewModel)
    }
    
    
    var body: some View {
        VStack{
            Form{
                Section(header : Text(expenseNameHeader), footer: Text(addExpensesViewModel.inlineErrorForExpenseName).foregroundColor(.red)){
                    TextField(expenseNameTextField, text: $addExpensesViewModel.expenseName)
                }
                
                
                Section(header : Text(paidByText)){
                    Picker(paidByText, selection: $addExpensesViewModel.expensePaidBy){
                        ForEach(addExpensesViewModel.peopleInTrip, id : \.self){ person in
                            Text(person.wrappedName)
                        }
                    }
                }
                
                
                Section(header: Text("\(expenseAmountHeader) (\(currencyManager.selectedCurrency))"),
                        footer: Text(addExpensesViewModel.inlineErrorForExpenseAmount).foregroundColor(.red)) {
                    TextField(expenseAmountTextField, text: $addExpensesViewModel.expenseCost)
                        .keyboardType(.decimalPad)
                    
                    // Display the equivalent amount in the footer
                    if !addExpensesViewModel.equivalentAmount.isEmpty {
                        Text("Equivalent in \(currencyManager.selectedCurrency == "USD" ? "Euro" : "USD"): \(addExpensesViewModel.equivalentAmount)")
                            .foregroundColor(.gray)
                    }
                }
                
                
                
                Section(header : Text(customSplitHeader)){
                    Toggle(isOn : $addExpensesViewModel.customSplitEnabled){
                        Text(customSplitToggleText)
                    }
                    if(addExpensesViewModel.customSplitEnabled){
                        VStack{
                            ForEach(0 ..< addExpensesViewModel.peopleInTrip.count, id : \.self){ item in
                                HStack{
                                    Text("\(addExpensesViewModel.peopleInTrip[item].wrappedName) \(toPay)")
                                    
                                    let placeholder = currencyManager.selectedCurrency == "USD" ? doubleDollar : "€€"
                                    
                                    HStack{
                                        Text(currencyManager.selectedCurrency == "USD" ? "$" : "€")
                                        TextField(placeholder, text: $addExpensesViewModel.splitAmounts[item])
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.decimalPad)
                                            
                                    }
                                }
                            }
                            Text(addExpensesViewModel.inlineErrorForSplitAmounts).foregroundColor(.red)
                        }
                        if addExpensesViewModel.selectedImage != nil {
                            Image(uiImage: addExpensesViewModel.selectedImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: imageWidth, height: imageHeight, alignment: .trailing)
                            
                        } else {
                            Image(systemName: defaultImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: imageWidth, height: imageHeight, alignment: .trailing)
                        }
                        Button(action: {addExpensesViewModel.isImagePickerDisplay.toggle()}){
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                .frame(height : buttonFrameHeight)
                                .overlay(Text(addPictureButtonText).foregroundColor(.white))
                        }.padding()
                    }
                }
            }
            Button(action : {addExpensesViewModel.addExpense(); self.mode.wrappedValue.dismiss()} ){
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .frame(height : buttonFrameHeight)
                    .overlay(Text(addExpenseButtonText).foregroundColor(.white))
            }
            .padding()
            .disabled(!addExpensesViewModel.isValid)
        }
        .navigationTitle(addExpenseNavigationTitle)
        .sheet(isPresented: $addExpensesViewModel.isImagePickerDisplay) {
            ImagePickerView(selectedImage: $addExpensesViewModel.selectedImage)
        }
    
    }
}
