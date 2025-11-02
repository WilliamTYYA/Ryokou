//
//  LandmarksHome.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

struct DestinationListView: View {
    @Environment(NavigationModel.self) private var navigationModel
    @State private var tripPlanViewModel: TripPlanViewModel = .init()
    
    @State private var searchText = ""
    
    private var filteredDestinations: [Destination] {
        ModelData.destinations.filter { lm in
            searchText.isEmpty || lm.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        @Bindable var navigationModel = navigationModel
        
        NavigationStack(path: $navigationModel.tripPlanPath) {
            ScrollView {
                Text("Where would you like to go today!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                if filteredDestinations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No matches")
                            .font(.headline)
                        Text("Try another city.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                } else {
                    LazyVStack(alignment: .center, spacing: 20) {
                        ForEach(filteredDestinations) { destination in
                            NavigationLink(value: TripPlanRoute.destination(destination)) {
                                DestinationListCardView(destination: destination)
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
            .navigationDestination(for: TripPlanRoute.self) { route in
                switch route {
                case .destination(let destination):
                    DestinationDetailView(destination: destination)
                    
                case .suggestions:
                    TripGenerationScreen(mode: .suggestions({ suggestion in
                        FlightAndAccomodationSuggestionView(suggestion: suggestion)
                    }))
                    
                case .itinerary:
                    TripGenerationScreen(mode: .itinerary({ itinerary in
                        ItineraryView(itinerary: itinerary)
                    }))
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Cities")
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .environment(tripPlanViewModel)
    }
}

struct DestinationListCardView: View {
    let destination: Destination
    
    var body: some View {
        Image(destination.thumbnailImageName)
            .resizable()
            .overlay {
                ReadabilityRoundedRectangle()
            }
            .overlay(alignment: .bottomLeading) {
                Text(destination.name)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
            }
            .cornerRadius(15.0)
            .clipped()
    }
}
