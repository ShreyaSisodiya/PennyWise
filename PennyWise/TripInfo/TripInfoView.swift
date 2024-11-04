//
//  TripInfoView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import SwiftUI

struct TripInfoView: View {
    
    @StateObject private var tripInfoViewModel : TripInfoViewModel
    let currentTrip : Trips
    
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
                Section(header : Text(addPersonHeader)){
                    Picker(peopleNamePickerText, selection: $tripInfoViewModel.personChosen){
                        ForEach(tripInfoViewModel.people, id : \.self){ item in
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
            
            NavigationLink(destination : ExpensesView(currentTrip: currentTrip), isActive: $tripInfoViewModel.moveToExpenses){
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
            
        }
        .navigationTitle(Text(currentTrip.wrappedName))
    }
}
