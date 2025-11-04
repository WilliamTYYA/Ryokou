//
//  LandmarksHome.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI
import SwiftData

struct SavedDestinationListView: View {
    @Query(sort: \TripPlan.departureDate, order: .reverse)
    private var tripPlans: [TripPlan]
    
    @State private var searchText = ""
    
    init(searchText: String) {
        let searchPredicate = #Predicate<TripPlan> {
            searchText.isEmpty ? true : $0.destinationName.localizedStandardContains(searchText)
        }
        _tripPlans = Query(filter: searchPredicate, sort: \.departureDate, order: .reverse)
    }
    
    var body: some View {
        ScrollView {
            if tripPlans.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Saved Trip Plans")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                LazyVStack(alignment: .center, spacing: 20) {
                    ForEach(tripPlans) { tripPlan in
                        NavigationLink(value: tripPlan) {
                            SavedDestinationListCardView(tripPlan: tripPlan)
                                .frame(height: 200)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TripPlan.self) { tripPlan in
            SavedItineraryView(tripPlan: tripPlan)
        }
    }
}

struct SavedDestinationListCardView: View {
    let tripPlan: TripPlan
    
    var body: some View {
        Image("\(tripPlan.destinationID)-thumb")
            .resizable()
            .overlay {
                ReadabilityRoundedRectangle()
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading) {
                    Text(tripPlan.destinationName)
                        .font(.title2)
                        .bold()
                    
                    Text("\(DateFormatter.shared.string(from: tripPlan.departureDate)) → \(DateFormatter.shared.string(from:tripPlan.returnDate))")
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding()
            }
            .cornerRadius(15.0)
            .clipped()
    }
}
