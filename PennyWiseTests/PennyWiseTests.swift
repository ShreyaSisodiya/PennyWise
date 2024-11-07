//
//  PennyWiseTests.swift
//  PennyWiseTests
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import Testing
import XCTest
import Combine
import PennyWise

@testable import PennyWise

class PennyWiseTests: XCTestCase {
    
    @Published var people : [People] = []
    private var cancellable : AnyCancellable?
    var peoplePublisher : AnyPublisher<[People], Never> = PeopleStorageTest.shared.people.eraseToAnyPublisher()
    
    @Published var trips : [Trips] = []
    var tripsPublisher : AnyPublisher<[Trips], Never> = TripsStorageTest.shared.trips.eraseToAnyPublisher()
    
    @Published var expenses : [Expenses] = []
    var expensesPublisher : AnyPublisher<[Expenses], Never> = ExpensesStorageTest.shared.expenses.eraseToAnyPublisher()

    func testAddPerson(){
        
        PeopleStorageTest.shared.add(name: "John", email: "john@gmail.com")
        cancellable = peoplePublisher.sink{ people in self.people = people }
        XCTAssertEqual(people.count, 5)
        for person in people {
            XCTAssertEqual(person.wrappedName, "John")
            XCTAssertEqual(person.wrappedEmail, "john@gmail.com")
        }
    }
    
    func testAddTrip(){
        
        TripsStorageTest.shared.add(tripName: "Six Flags")
        cancellable = tripsPublisher.sink{ trips in self.trips = trips }
        XCTAssertEqual(trips.count, 3)
        for trip in trips {
            XCTAssertEqual(trip.wrappedName, "Six Flags")
        }
    }
    
    
    func testAddPeopleToTrip(){
        
        PeopleStorageTest.shared.add(name: "John", email: "john@gmail.com")
        TripsStorageTest.shared.add(tripName: "Six Flags")
        
        cancellable = peoplePublisher.sink{ people in self.people = people }
        cancellable = tripsPublisher.sink{ trips in self.trips = trips }
        
        var namesArray = [String]()
        var emailsArray = [String]()
        for person in people {
            namesArray.append(person.wrappedName)
            emailsArray.append(person.wrappedEmail)
        }
        
        TripsStorageTest.shared.addPeopleToTrip(currentTrip: trips[0], peopleNames: namesArray, peopleEmails: emailsArray)
        
        XCTAssertEqual(trips[0].peopleArray.count, 2)
        XCTAssertEqual(people.count, 2)
        XCTAssertEqual(trips[0].peopleArray[0].tripArray[0].wrappedName, trips[0].wrappedName)
    }
    
    func testAddExpenseToTrip(){
       
        PeopleStorageTest.shared.add(name: "John", email: "john@gmail.com")
        TripsStorageTest.shared.add(tripName: "Six Flags")
        
        cancellable = peoplePublisher.sink{ people in self.people = people }
        cancellable = tripsPublisher.sink{ trips in self.trips = trips }
            
        ExpensesStorageTest.shared.add(name: "Breakfast", amount: "40", paidBy: people[0] , currentTrip: trips[0])
        cancellable = expensesPublisher.sink{ expenses in self.expenses = expenses }
        XCTAssertEqual(expenses.count, 1)
        for expense in expenses {
            XCTAssertEqual(expense.belongsToTrip, trips[0])
            XCTAssertEqual(expense.paidBy, people[0])
        }
    }

}
