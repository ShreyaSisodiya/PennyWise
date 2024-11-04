//
//  AddTripView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/1/24.
//

import SwiftUI

struct AddTripView: View {
    
    @StateObject private var addTripViewModel = AddTripViewModel()
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack{
            Form{
                Section(header : Text(tripNameHeader), footer : Text(addTripViewModel.inlineErrorForTripName).foregroundColor(.red)){
                    TextField(tripNameTextField, text: $addTripViewModel.tripName)
                }
                Section(header : Text(tripDurationHeader)){
                    DatePicker(tripDurationFrom, selection: $addTripViewModel.durationFrom, displayedComponents: .date)
                    DatePicker(tripDurationTo, selection: $addTripViewModel.durationTo, displayedComponents: .date)
                }
                Section(header : Text(tripPeopleHeader), footer: Text(addTripViewModel.inlineErrorForPeople).foregroundColor(.red)){
                    List{
                        ForEach(addTripViewModel.peopleNames, id : \.self){name in
                            Text(name)
                        }
                    }
                    Button(action : addTripViewModel.deletePerson){
                        Image(systemName: backspace).imageScale(.large)
                    }
                }
                Section(header : Text(addAPersonHeader)){
                    Picker(peopleNamePickerText, selection: $addTripViewModel.personChosen){
                        ForEach(addTripViewModel.people, id : \.self){ item in
                            Text(item.wrappedName)
                        }
                    }
                    Button(action: addTripViewModel.addPerson){
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .frame(height : buttonFrameHeight)
                            .overlay(Text(addPersonButtonText).foregroundColor(.white))
                    }.padding()
                        .disabled(!addTripViewModel.personIsValid)
                }
                Section(header : Text(addNewPersonHeader)){
                    TextField(newNameText, text: $addTripViewModel.newPersonName)
                    TextField(newEmailText, text: $addTripViewModel.newPersonEmail).autocapitalization(.none)
                    Button(action: addTripViewModel.addNewPerson){
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .frame(height : buttonFrameHeight)
                            .overlay(Text(addNewPersonButtonText).foregroundColor(.white))
                    }.padding()
                        .disabled(!addTripViewModel.newPersonIsValid)
                }
            }
            Button(action : {addTripViewModel.addTrip(); self.mode.wrappedValue.dismiss()}){
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .frame(height : buttonFrameHeight)
                    .overlay(Text(addTripButtonText).foregroundColor(.white))
            }
            .padding()
            .disabled(!addTripViewModel.isValid)
        }
        .navigationTitle(addTripNavigationTitle)
    }
}
