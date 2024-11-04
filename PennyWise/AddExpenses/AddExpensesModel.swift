//
//  AddExpensesModel.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/4/24.
//

import Foundation
import CoreGraphics

// Constants
let expenseNameHeader : String = "Expense Name"
let expenseNameTextField : String = "Enter Expense Name"
let paidByText : String = "Paid By"
let expenseAmountHeader : String = "Expense Amount"
let expenseAmountTextField : String = "Enter Expense Amount"
let customSplitHeader : String = "Custom Split"
let customSplitToggleText : String = "Enable Custom Split :"
let imageHeight : CGFloat = 300
let imageWidth :CGFloat = 300
let defaultImageName : String = "snow"
let doubleDollar : String = "$$"
let toPay : String = "to pay :"
let addPictureButtonText : String = "Add Picture"
let addExpenseButtonText : String = "Add Expense"
let addExpenseNavigationTitle : String = "Add an Expense"
let expenseNameErrorText : String = "Expense Name Field Cannot be Empty"
let expenseAmountEmptyErrorText : String = "Expense Amount Field Cannot be Empty"
let expenseAmountNotCorrectErrorText : String = "Expense Amount Is Not Valid"
let splitErrorText : String = "The Split Does not Cover the Entire Expense"

// Enumerations for Publishers
enum ExpenseAmountStatus{
    case empty
    case notCorrect
    case valid
}
