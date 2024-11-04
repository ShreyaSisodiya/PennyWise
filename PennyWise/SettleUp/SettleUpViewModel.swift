//
//  SettleUpViewModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import Foundation

class SettleUpViewModel : ObservableObject{
    
    let currentTrip : Trips
    var finalSettlements = [String : [String : [Double]]]()
    
    @Published var mailData = MailData(subject: "", recipients: nil, message: "")
    @Published var showMailView = false
    
    init(currentTrip : Trips){
        self.currentTrip = currentTrip
        performCalculations()
        composeMail()
    }
    
    func performCalculations(){
        
        for item in 0 ..< currentTrip.peopleArray.count{
            var dictionary = [String : [Double]]()
            for expense in currentTrip.expensesArray{
                guard let splitArray = expense.split?.components(separatedBy: ";"), splitArray.count > item else { continue }
                
                if let paidBy = expense.paidBy, paidBy != currentTrip.peopleArray[item]{
                    let wrappedName = paidBy.wrappedName
                    let value = splitArray[item]
                    
                    if !value.isEmpty, let amount = Double(value){
                        if dictionary[wrappedName] != nil {
                            dictionary[wrappedName]?.append(amount)
                        } else {
                            dictionary[wrappedName] = [amount]
                        }
                    } else{
                        print("Error: Value at index \(item) is invalid or empty")
                    }
                }
            }
            finalSettlements[currentTrip.peopleArray[item].wrappedName] = dictionary
        }
    }
    
    func composeMail(){
        
        var recipients  = [String]()
        for person in currentTrip.peopleArray{
            recipients.append(person.wrappedEmail)
        }
        var message = "\(newLine) \(tripNameText) \(currentTrip.wrappedName) \(newLine)\(newLine)"
        for (key, value) in  finalSettlements{
            message += "\(key) \(collon) \(newLine)"
            if value.isEmpty{
                message += "\(owesNothingText) \(newLine)"
            }
            else{
                for (key1, value1) in value{
                    message += "\(owes) \(key1) \(value1.reduce(0, +))\(dollar) \(newLine)"
                }
            }
        
        }
        mailData = MailData(subject: mailSubject, recipients: recipients, message: message)
    }
}
