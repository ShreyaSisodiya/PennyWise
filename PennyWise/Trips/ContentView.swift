//
//  ContentView.swift
//  PennyWise
//
//  Created by Shreya Sisodiya on 10/30/24.
//

//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    @StateObject private var tripsViewModel = TripsViewModel()
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(tripsViewModel.trips, id: \.self) { trip in
//                    NavigationLink(destination: TripInfoView(context: viewContext, currentTrip: trip)) {
//                        VStack(alignment: .leading, spacing: tripsVStackSpacing) {
//                            Text(trip.wrappedName)
//                            Text(trip.wrappedDuration)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        .frame(height: tripsVStackHeight)
//                    }
//                }
//            }
//            .navigationTitle(tripsNavigationTitle)
//            .toolbar {
//                NavigationLink(destination: AddTripView()) {
//                    Image(systemName: plusImage).imageScale(.large)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var tripsViewModel = TripsViewModel()

    var body: some View {
        NavigationView{
            List{
                ForEach(tripsViewModel.trips, id : \.self){trip in
                    NavigationLink(destination : TripInfoView(currentTrip: trip, tripInfoViewModel: TripInfoViewModel(currentTrip: trip))){
                        VStack(alignment: .leading, spacing: tripsVStackSpacing){
                            Text(trip.wrappedName)
                            Text(trip.wrappedDuration).font(.subheadline).foregroundColor(.gray)
                        }.frame(height : tripsVStackHeight)
                    }
                }
            }
            .navigationTitle(tripsNavigationTitle)
            .toolbar{
                NavigationLink(destination : AddTripView()){
                    Image(systemName: plusImage).imageScale(.large)
                }
            }
        }
    }
}

