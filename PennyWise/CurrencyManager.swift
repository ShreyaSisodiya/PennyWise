//
//  CurrencyManager.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 11/5/24.
//


//import Foundation
//
//class CurrencyManager: ObservableObject {
//    @Published var selectedCurrency: String = "USD" // Default to USD
//
//    func formatAmount(_ amount: Double, currency: String) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        
//        if currency == "Euro" {
//            formatter.locale = Locale(identifier: "fr_FR") // Locale for Euro
//            return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) €"
//        } else {
//            formatter.locale = Locale(identifier: "en_US") // Locale for USD
//            return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
//        }
//    }
//
//    func convertUSDtoEuro(_ amount: Double) -> Double {
//        let exchangeRate = 0.9 // Example exchange rate for USD to Euro
//        return amount * exchangeRate
//    }
//
//    func convertEuroToUSD(_ amount: Double) -> Double {
//        let exchangeRate = 0.9 // Same exchange rate, used inversely for Euro to USD
//        return amount / exchangeRate
//    }
//}

import Foundation

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        }
    }
    
    init() {
        // Retrieve saved currency type from UserDefaults or default to "USD"
        self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
    }

    func formatAmount(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if currency == "Euro" {
            formatter.locale = Locale(identifier: "fr_FR") // Locale for Euro
            return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) €"
        } else {
            formatter.locale = Locale(identifier: "en_US") // Locale for USD
            return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
        }
    }

    func convertUSDtoEuro(_ amount: Double) -> Double {
        let exchangeRate = 0.9 // Example exchange rate for USD to Euro
        return amount * exchangeRate
    }

    func convertEuroToUSD(_ amount: Double) -> Double {
        let exchangeRate = 0.9 // Same exchange rate, used inversely for Euro to USD
        return amount / exchangeRate
    }
}
