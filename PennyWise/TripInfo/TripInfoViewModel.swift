//
//  TripInfoViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/2/24.
//

import Foundation
import Combine
import CoreData

class TripInfoViewModel : ObservableObject{
    
    @Published var people : [People] = []
    
    private var cancellable : AnyCancellable?
    var peoplePublisher : AnyPublisher<[People], Never> = PeopleStorage.shared.people.eraseToAnyPublisher()
    
    var currentTrip : Trips?
    
    @Published var peopleNames = [String]()
    @Published var peopleEmails = [String]()
    @Published var newPersonName : String = ""
    @Published var newPersonEmail : String = ""
    @Published var personChosen : People = People()
    @Published var moveToExpenses : Bool = false
    @Published var moveToSettleUp : Bool = false
    @Published var newPersonIsValid : Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @Published var inlineErrorForEmail: String = ""
    @Published var inlineErrorForPeople : String = ""

    
    private var isNewPersonEmailUniquePublisher: AnyPublisher<Bool, Never> {
        $newPersonEmail
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { newEmail in
                // Skip the check if the input is empty
                guard !newEmail.isEmpty else {
                    self.inlineErrorForEmail = ""
                    return true // Assume valid when empty to avoid showing an error initially
                }

                // Check if the email is in a valid format before checking uniqueness
                if self.isValidEmail(newEmail) {
                    let isUnique = !PeopleStorage.shared.doesPersonExist(withEmail: newEmail)
                    self.inlineErrorForEmail = isUnique ? "" : "A person with this email already exists across all trips."
                    return isUnique
                } else {
                    // Don't show any error for incomplete or invalid emails
                    self.inlineErrorForEmail = ""
                    return true // Assume valid until the input is a complete, valid email
                }
            }
            .eraseToAnyPublisher()
    }


    private var isNewPersonNameUniquePublisher: AnyPublisher<Bool, Never> {
        $newPersonName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { newName in
                let isUnique = !PeopleStorage.shared.doesPersonExist(withName: newName)
                self.inlineErrorForPeople = isUnique ? "" : "A person with this name already exists across all trips."
                return isUnique
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
    
    private var isNewPersonValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            isNewPersonNameEmptyPublisher,
            isNewPersonEmailEmptyPublisher,
            isNewPersonEmailUniquePublisher,
            isNewPersonNameUniquePublisher
        )
        .map { isNameEmpty, isEmailEmpty, isEmailUnique, isNameUnique in
            !isNameEmpty && !isEmailEmpty && isEmailUnique && isNameUnique
        }
        .eraseToAnyPublisher()
    }


    
    init(currentTrip : Trips){
        self.currentTrip = currentTrip
        cancellable = peoplePublisher.sink{ people in
            self.people = people
            //self.updatePeopleList(with: people)

            // Print to check the unique list
//            self.people.forEach { person in
//                print("Loaded unique person: \(person.wrappedName) with email: \(person.wrappedEmail)")
//            }
            
//            people.forEach { person in
//                print("Loaded person email: \(person.wrappedEmail)")
//            }
            
            DispatchQueue.main.async {
                //if !self.people.isEmpty {
                    self.personChosen = self.people[0]
                //}
            }
        }
        
//        for person in people{
//            if person.tripArray.contains(currentTrip){
//                peopleNames.append(person.wrappedName)
//                peopleEmails.append(person.wrappedEmail)
//            }
//        }
        
        for person in people {
            if person.tripArray.contains(currentTrip) {
                if !peopleNames.contains(person.wrappedName) {
                    peopleNames.append(person.wrappedName)
                }
                if !peopleEmails.contains(person.wrappedEmail) {
                    peopleEmails.append(person.wrappedEmail)
                }
            }
        }
        
        isNewPersonValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.newPersonIsValid, on: self)
            .store(in: &cancellables)
    }

    
    func addPerson() {
        // Check if the chosen person's name is already in the peopleNames list
        if !peopleNames.contains(personChosen.wrappedName) {
            peopleNames.append(personChosen.wrappedName)
            peopleEmails.append(personChosen.wrappedEmail)
        } else {
            // Optionally, show an error message or alert indicating the name is already added
            NSLog("Person with this name is already in the list.")
        }
    }

    
    func addNewPerson() {

        if !peopleNames.contains(newPersonName.lowercased()) && !peopleEmails.contains(newPersonEmail.lowercased()) {
            peopleNames.append(newPersonName)
            peopleEmails.append(newPersonEmail)
            newPersonName = ""
            newPersonEmail = ""
        } else {
            // Set an inline error or show a warning if a duplicate is found
            inlineErrorForEmail = "A person with this name or email already exists in the trip."
        }
    }

    
    func confirmChanges(currentTrip : Trips){
        TripsStorage.shared.addPeopleToTrip(currentTrip: currentTrip, peopleNames: peopleNames, peopleEmails: peopleEmails)
    }
    
    func settleUp(){
        print(people)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

