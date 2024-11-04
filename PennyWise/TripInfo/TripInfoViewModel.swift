//
//  TripInfoViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/2/24.
//

import Foundation
import Combine

class TripInfoViewModel : ObservableObject{
    
    @Published var people : [People] = []
    private var cancellable : AnyCancellable?
    var peoplePublisher : AnyPublisher<[People], Never> = PeopleStorage.shared.people.eraseToAnyPublisher()
    
    var currentTrip : Trips?
    
    @Published var peopleNames = [String]()
    @Published var peopleEmails = [String]()
    @Published var newPersonName : String = ""
    @Published var newPersonEmail : String = ""
    //@Published var personChosen : People = People()
    @Published var personChosen: People?
    @Published var moveToExpenses : Bool = false
    @Published var moveToSettleUp : Bool = false
    @Published var newPersonIsValid : Bool = false
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private var isNewPersonValidPublisher : AnyPublisher<Bool, Never>{
        Publishers.CombineLatest(isNewPersonNameEmptyPublisher, isNewPersonEmailEmptyPublisher)
            .map{
                !$0 && !$1
            }
            .eraseToAnyPublisher()
    }
    
    
    init(currentTrip : Trips){
        self.currentTrip = currentTrip
        
        cancellable = peoplePublisher.sink{ [weak self] people in
            guard let self = self else { return }
            self.people = people
            DispatchQueue.main.async {
                // Safely assign a valid 'People' object if 'people' is not empty
                if let firstPerson = self.people.first {
                    self.personChosen = firstPerson
                } else {
                    self.personChosen = nil
                }
            }
        }
        for person in people{
            if person.tripArray.contains(currentTrip){
                peopleNames.append(person.wrappedName)
                peopleEmails.append(person.wrappedEmail)
            }
        }
        
        isNewPersonValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.newPersonIsValid, on: self)
            .store(in: &cancellables)
    }
    
//    func addPerson(){
//            peopleNames.append(personChosen!.wrappedName)
//            peopleEmails.append(personChosen!.wrappedEmail)
//    }
    
    func addPerson() {
        if let chosenPerson = personChosen {
            peopleNames.append(chosenPerson.wrappedName)
            peopleEmails.append(chosenPerson.wrappedEmail)
        }
    }

    
    func addNewPerson(){
        peopleNames.append(newPersonName)
        peopleEmails.append(newPersonEmail)
        newPersonName = ""
        newPersonEmail = ""
    }
    
    func confirmChanges(currentTrip : Trips){
        TripsStorage.shared.addPeopleToTrip(currentTrip: currentTrip, peopleNames: peopleNames, peopleEmails: peopleEmails)
    }
    
    func settleUp(){
        print(people)
    }

}

