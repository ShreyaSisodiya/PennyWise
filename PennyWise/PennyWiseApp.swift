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

    var body: some Scene {
        WindowGroup {
           //ContentView()
            AddTripView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            //AddTripView()
        }
    }
}
