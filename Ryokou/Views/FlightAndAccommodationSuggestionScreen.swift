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
    @State private var vm        = FlightAndAccommodationSuggestionViewModel()
    
    var body: some View {
        ScrollView {
            if let suggestion = generator.suggestion {
                FlightAndAccomodationSuggestionView(viewModel: vm, suggestion: suggestion)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Confirm") {
                                guard let f = vm.selectedFlight, let h = vm.selectedHotel else { return }
                                onConfirm(SelectedOptions(flight: f, hotel: h))
                            }
                            .disabled(!vm.canConfirm)
                        }
                    }
            } else {
                ProgressView("Finding options…")
            }
        }
        .headerStyle(destination: context.destination)
        .task(id: context) {
            guard generator.suggestion == nil else { return }
            await generator.generateTripSuggestion(context: context)
        }
    }
}
