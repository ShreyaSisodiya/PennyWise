//
//  AddTripView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/1/24.
//

import SwiftUI
import CoreData

struct AddTripView: View {
    
    //@StateObject private var addTripViewModel = AddTripViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var addTripViewModel: AddTripViewModel

    // Custom initializer
    init(context: NSManagedObjectContext) {
        _addTripViewModel = StateObject(wrappedValue: AddTripViewModel(context: context))
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section(header: Text(tripNameHeader), footer: Text(addTripViewModel.inlineErrorForTripName).foregroundColor(.red)){
                        TextField(tripNameTextField, text: $addTripViewModel.tripName)
                    }
                    
                    Section(header: Text(tripDurationHeader)){
                        DatePicker(tripDurationFrom, selection: $addTripViewModel.durationFrom)
                        DatePicker(tripDurationTo, selection: $addTripViewModel.durationTo)
                    }
                    
                    Section(header: Text(tripPeopleHeader), footer: Text(addTripViewModel.inlineErrorForPeople).foregroundColor(.red)){
                        List{
                            ForEach(addTripViewModel.peopleNames, id: \.self){ name in
                                Text(name)
                            }
                        }
                        Button(action: addTripViewModel.deletePerson){
                            Image(systemName: backspace).imageScale(.large)
                        }
                    }
                    
                    Section(header: Text(addPersonHeader)) {
                        Picker(peopleNamePickerText, selection: $addTripViewModel.personChosen){
                            ForEach(addTripViewModel.people, id: \.self){ item in
                                Text(item.wrappedName)
                            }
                        }
                        Button(action: addTripViewModel.addPerson){
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                .frame(height: buttonFrameHeight)
                                .overlay(Text(addPersonButtonText).foregroundColor(.white))
                        }.padding()
                    }
                    
                    Section(header: Text(addNewPersonHeader)){
                        TextField(newNameText, text: $addTripViewModel.newPersonName)
                        TextField(newEmailText, text: $addTripViewModel.newPersonEmail)
                        Button(action: addTripViewModel.addNewPerson){
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                .frame(height: buttonFrameHeight)
                                .overlay(Text(addNewPersonButtonText).foregroundColor(.white))
                        }.padding()
                            .disabled(!addTripViewModel.newPersonIsValid)
                    }
                }
                
                Button(action: addTripViewModel.addTrip){
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .frame(height: buttonFrameHeight)
                        .overlay(Text(addTripButtonText).foregroundColor(.white))
                }
                .padding()
                .disabled(!addTripViewModel.isValid)
            }
            .navigationTitle(addTripNavigationTitle)
        }
    }
}

#Preview {
    AddTripView(context: PersistenceController.shared.container.viewContext)
}
