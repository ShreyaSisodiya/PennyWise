//
//  TripInfoView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//
extension Array {
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

import SwiftUI

struct TripInfoView: View {
    
    @StateObject private var tripInfoViewModel : TripInfoViewModel
    let currentTrip : Trips
    @EnvironmentObject var currencyManager: CurrencyManager
    
    init(currentTrip : Trips, tripInfoViewModel : TripInfoViewModel){
        self.currentTrip = currentTrip
        self._tripInfoViewModel = StateObject(wrappedValue: tripInfoViewModel)
    }
    
    var body: some View {
            VStack{
                Form{
                    Section(header : Text(tripPeopleHeader)){
                        List{
                            ForEach(tripInfoViewModel.peopleNames, id : \.self){name in
                                Text(name)
                            }
                        }
                    }
                    
                    // Currency Picker Section
                    Section(header: Text("Edit Currency Type")) {
                        Picker("Currency", selection: $currencyManager.selectedCurrency) {
                            Text("USD").tag("USD")
                            Text("Euro").tag("Euro")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header : Text(addPersonHeader)){
                        Picker(peopleNamePickerText, selection: $tripInfoViewModel.personChosen) {
                            ForEach(tripInfoViewModel.people.removingDuplicates(by: \.wrappedEmail), id: \.self) { item in
                                Text(item.wrappedName)
                            }
                        }
                        Button(action: tripInfoViewModel.addPerson){
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                .frame(height : buttonFrameHeight)
                                .overlay(Text(addPersonButtonText).foregroundColor(.white))
                        }.padding()
                    }
                    
                    Section(header : Text(addNewPersonHeader)){
                        TextField(newNameText, text: $tripInfoViewModel.newPersonName)
                        TextField(newEmailText, text: $tripInfoViewModel.newPersonEmail).autocapitalization(.none)
                        
                        // Display the error message in red
                        if !tripInfoViewModel.inlineErrorForEmail.isEmpty {
                            Text(tripInfoViewModel.inlineErrorForEmail)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: tripInfoViewModel.addNewPerson){
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                .frame(height : buttonFrameHeight)
                                .overlay(Text(addNewPersonButtonText).foregroundColor(.white))
                        }.padding()
                            .disabled(!tripInfoViewModel.newPersonIsValid)
                    }
                    
                    Button(action: {tripInfoViewModel.confirmChanges(currentTrip: currentTrip)}){
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .frame(height : buttonFrameHeight)
                            .overlay(Text(confirmChangesButtonText).foregroundColor(.white))
                    }.padding()
                    
                }
                                
            }
            NavigationLink(destination : ExpensesView(currentTrip: currentTrip).environmentObject(currencyManager), isActive: $tripInfoViewModel.moveToExpenses){
                Button(action: {tripInfoViewModel.moveToExpenses = true}){
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .frame(height : buttonFrameHeight)
                        .overlay(Text(expensesButtonText).foregroundColor(.white))
                }.padding()
            }
            
            
            NavigationLink(destination: SettleUpView(settleUpViewModel: SettleUpViewModel(currentTrip: currentTrip)), isActive: $tripInfoViewModel.moveToSettleUp){
                Button(action: {tripInfoViewModel.moveToSettleUp = true}){
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .frame(height : buttonFrameHeight)
                        .overlay(Text(settleUpButtonText).foregroundColor(.white))
                }.padding()
            

        }
        .navigationTitle(Text(currentTrip.wrappedName))
    }
}
