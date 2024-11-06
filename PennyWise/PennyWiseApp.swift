//
//  PennyWiseApp.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import SwiftUI

@main
struct PennyWiseApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var currencyManager = CurrencyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(currencyManager)
        }
    }
}
