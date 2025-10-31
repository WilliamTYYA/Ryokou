//
//  NewFlightAndAccommodationSuggestionView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import SwiftUI

struct FlightAndAccommodationSuggestionScreen: View {
    let context: TripContext
    let onConfirm: (SelectedOptions) -> Void
    
    @State private var generator = FlightAndAccommodationSuggestionGenerator()
    @State private var viewModel = FlightAndAccommodationSuggestionViewModel()
    
    var body: some View {
        ScrollView {
            if let suggestion = generator.suggestion {
                FlightAndAccomodationSuggestionView(viewModel: viewModel, suggestion: suggestion)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Confirm") {
                                guard let f = viewModel.selectedFlight, let h = viewModel.selectedHotel else { return }
                                onConfirm(SelectedOptions(flight: f, hotel: h))
                            }
                            .disabled(!viewModel.canConfirm)
                        }
                    }
            } else {
                ProgressView("Finding options…")
            }
        }
        .headerStyle(destination: context.destination)
        .task(id: context) {
            Log.i("FlightAndAccommodationSuggestionScreen", "Task is invoking for Generator!")
            guard generator.suggestion == nil else { return }
            await generator.generateTripSuggestion(context: context)
        }
    }
}
