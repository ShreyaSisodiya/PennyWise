//
//  ContentView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var tripsViewModel = TripsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tripsViewModel.trips, id: \.self){ trip in
                    Text(trip.name?.capitalized ?? "No Name")
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
