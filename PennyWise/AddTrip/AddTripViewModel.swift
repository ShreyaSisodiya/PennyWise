//
//  AddTripViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/1/24.
//

import Foundation
import Combine

class AddTripViewModel: ObservableObject {
    
    @Published var people: [People] = []
    private var cancellable: AnyCancellable?
    var peoplePublisher: AnyPublisher<[People], Never> = PeopleStorage.shared.people.eraseToAnyPublisher()
    
    @Published var tripName: String = ""
    @Published var durationFrom: Date = Date.now
    @Published var durationTo: Date = Date.now.addingTimeInterval(secondsInDay)
    
    @Published var peopleNames = [String]()
    @Published var peopleEmails = [String]()
    @Published var newPersonName: String = ""
    @Published var newPersonEmail: String = ""
    @Published var personChosen: People = People()
    @Published var inlineErrorForTripName: String = ""
    @Published var inlineErrorForPeople: String = ""
    @Published var isValid: Bool = false
    @Published var newPersonIsValid: Bool = false
    
    private var cancellabes = Set<AnyCancellable>()
    
    private var isTripNameEmptyPublisher: AnyPublisher<Bool, Never> {
        $tripName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isNewPersonNameEmptyPublisher: AnyPublisher<Bool, Never> {
        $newPersonName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isNewPersonEmailEmptyPublisher: AnyPublisher<Bool, Never> {
        $newPersonEmail
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isNewPersonValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isNewPersonNameEmptyPublisher, isNewPersonEmailEmptyPublisher)
            .map {
                !$0 && !$1
            }
            .eraseToAnyPublisher()
    }
    
    private var isPeopleEmptyPublisher: AnyPublisher<Bool, Never> {
        $peopleNames
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {$0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isTripNameEmptyPublisher, isPeopleEmptyPublisher)
            .map {
                !$0 && !$1
            }
            .eraseToAnyPublisher()
    }
    
    init(){
        cancellable = peoplePublisher.sink { people in
            self.people = people
            DispatchQueue.main.async{
                self.personChosen = self.people[0]
            }
        }
        
        isTripNameEmptyPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { status in
                if status { return tripNameErrorText }
                else { return ""}
            }
            .assign(to: \.inlineErrorForTripName, on: self)
            .store(in: &cancellabes)
        
        isPeopleEmptyPublisher
            .receive(on: RunLoop.main)
            .map { status in
                if status { return peopleErrorText }
                else { return ""}
            }
            .assign(to: \.inlineErrorForPeople, on: self)
            .store(in: &cancellabes)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellabes)
        
        isNewPersonValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.newPersonIsValid, on: self)
            .store(in: &cancellabes)
    }
    
    func addPerson(){
        peopleNames.append(personChosen.wrappedName)
        peopleEmails.append(personChosen.wrappedEmail)
    }
    
    func addNewPerson(){
        peopleNames.append(newPersonName)
        peopleEmails.append(newPersonEmail)
        newPersonName = ""
        newPersonEmail = ""
    }
    
    func deletePerson(){
        if !peopleNames.isEmpty {
            peopleNames.removeLast()
            peopleEmails.removeLast()
        }
    }
    
    func addTrip(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let tripDuration: String = dateFormatter.string(from: durationFrom) + to + dateFormatter.string(from: durationTo)
        
        TripsStorage.shared.add(tripName: tripName, tripDuration: tripDuration, peopleNames: peopleNames, peopleEmails: peopleEmails)
    }
}

