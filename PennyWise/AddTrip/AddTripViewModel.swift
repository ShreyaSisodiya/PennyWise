//
//  AddTripViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/1/24.
//

import Foundation
import Combine

class AddTripViewModel : ObservableObject{
    
    @Published var people : [People] = []
    private var cancellable : AnyCancellable?
    var peoplePublisher : AnyPublisher<[People], Never> = PeopleStorage.shared.people.eraseToAnyPublisher()
    
    @Published var tripName : String = ""
    @Published var durationFrom : Date = Date.now
    @Published var durationTo : Date = Date.now.addingTimeInterval(secondsInDay)
    
    @Published var peopleNames = [String]()
    @Published var peopleEmails = [String]()
    @Published var newPersonName : String = ""
    @Published var newPersonEmail : String = ""
    //@Published var personChosen : People = People()
    @Published var personChosen: People?
    
    @Published var inlineErrorForTripName : String = ""
    @Published var inlineErrorForPeople : String = ""
    @Published var inlineErrorForEmail: String = ""

    @Published var isValid : Bool = false
    @Published var newPersonIsValid : Bool = false
    @Published var personIsValid : Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isTripNameEmptyPublisher : AnyPublisher<Bool, Never>{
        $tripName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isTripNameUniquePublisher: AnyPublisher<Bool, Never> {
        $tripName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { name in
                !TripsStorage.shared.doesTripExist(withName: name)
            }
            .eraseToAnyPublisher()
    }
    
    private var tripNameErrorPublisher: AnyPublisher<String, Never> {
        $tripName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { name in
                if name.isEmpty {
                    return "" // No error when the name is empty; handle this with the existing empty check
                } else if !TripsStorage.shared.doesTripExist(withName: name) {
                    return "" // No error if the name is unique
                } else {
                    return "A trip with this name already exists. Please choose a different name."
                }
            }
            .eraseToAnyPublisher()
    }

    private var isNewPersonNameEmptyPublisher : AnyPublisher<Bool, Never>{
        $newPersonName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isNewPersonEmailEmptyPublisher : AnyPublisher<Bool, Never>{
        $newPersonEmail
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isNewPersonEmailUniquePublisher: AnyPublisher<Bool, Never> {
        $newPersonEmail
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { newEmail in
                // Check if the new email already exists in the current list of peopleEmails
                return !self.peopleEmails.contains(newEmail.lowercased())
            }
            .eraseToAnyPublisher()
    }

    
    private var isNewPersonValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isNewPersonNameEmptyPublisher, isNewPersonEmailEmptyPublisher, isNewPersonEmailUniquePublisher)
            .map { isNameEmpty, isEmailEmpty, isEmailUnique in
                !isNameEmpty && !isEmailEmpty && isEmailUnique
            }
            .eraseToAnyPublisher()
    }


    private var isPersonValidPublisher : AnyPublisher<Bool, Never>{
        $personIsValid
            .map { _ in !self.people.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var isPeopleEmptyPublisher : AnyPublisher<Bool, Never>{
        $peopleNames
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isTripNameEmptyPublisher, isPeopleEmptyPublisher, isTripNameUniquePublisher)
            .map { isTripNameEmpty, isPeopleEmpty, isTripNameUnique in
                !isTripNameEmpty && !isPeopleEmpty && isTripNameUnique
            }
            .eraseToAnyPublisher()
    }

    
    init(){
        cancellable = peoplePublisher.sink{ people in
            self.people = people
            DispatchQueue.main.async {
                if !self.people.isEmpty {
                    self.personChosen = self.people.first // Safely unwrap to avoid `nil`
                } else {
                    self.personChosen = nil // Set to `nil` if `people` is empty
                }
            }
        }
        
        isTripNameEmptyPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { status in
                if status {return tripNameErrorText}
                else {return ""}
            }
            .assign(to: \.inlineErrorForTripName, on: self)
            .store(in: &cancellables)
        
        tripNameErrorPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.inlineErrorForTripName, on: self)
                .store(in: &cancellables)
        
        isPeopleEmptyPublisher
            .receive(on: RunLoop.main)
            .map { status in
                if status {return peopleErrorText}
                else {return ""}
            }
            .assign(to: \.inlineErrorForPeople, on: self)
            .store(in: &cancellables)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
        
        isNewPersonValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.newPersonIsValid, on: self)
            .store(in: &cancellables)
        
        isPersonValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.personIsValid, on: self)
            .store(in: &cancellables)
        
    }
    
    func addPerson(){
            peopleNames.append(personChosen!.wrappedName)
            peopleEmails.append(personChosen!.wrappedEmail)
    }
    
    func addNewPerson() {
        // Check if the new person email already exists in the list
        if !peopleEmails.contains(newPersonEmail.lowercased()) {
            peopleNames.append(newPersonName)
            peopleEmails.append(newPersonEmail)
            newPersonName = ""
            newPersonEmail = ""
        } else {
            // Optionally, set an inline error or show a warning if desired
            inlineErrorForPeople = "A person with this email already exists in the trip."
        }
    }


    
    func deletePerson(){
        if !peopleNames.isEmpty{
            peopleNames.removeLast()
            peopleEmails.removeLast()
        }
    }
    
    func addTrip() {
        // The form is already validated by isFormValidPublisher, so this function only needs to add the trip
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let tripDuration: String = dateFormatter.string(from: durationFrom) + to + dateFormatter.string(from: durationTo)
        
        TripsStorage.shared.add(tripName: tripName, tripDuration: tripDuration, peopleNames: peopleNames, peopleEmails: peopleEmails)
        
        // Optionally clear the form or perform other post-save actions if needed
        inlineErrorForTripName = ""
    }
}
