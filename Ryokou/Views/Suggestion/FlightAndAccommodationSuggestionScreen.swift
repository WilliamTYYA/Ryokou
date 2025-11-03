//
//  NewFlightAndAccommodationSuggestionView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import SwiftUI

struct FlightAndAccommodationSuggestionScreen: View {
    @Environment(TripPlanViewModel.self) private var tripPlanViewModel
    
    var body: some View {
        let generator = tripPlanViewModel.tripSuggestionItineraryGenerator
        let context = tripPlanViewModel.tripContext
        
        ScrollView {
            if let suggestion = generator?.suggestion {
                FlightAndAccomodationSuggestionView(suggestion: suggestion)
                    .padding()
            } else {
                ProgressView("Finding Options...")
                    .padding(.top, 120)
                    .padding(.top)
            }
        }
        .headerStyle(destination: context!.destination)
        .task(id: context) {
            guard generator?.suggestion == nil || context != generator?.tripContext else { return }
            Log.i("FlightAndAccommodationSuggestionScreen", "Task is invoking for Generator!")
            await generator?.generateFlightAndHotelSuggestion(context: context!)
        }
    }
}
