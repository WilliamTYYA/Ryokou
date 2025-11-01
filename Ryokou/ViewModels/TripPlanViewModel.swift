//
//  TripPlanViewModel.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import Foundation
import Observation

@Observable
class TripPlanViewModel {
    private(set) var generatorFlightAndAccommodation: FlightAndAccommodationSuggestionGenerator?
    
    var tripContext: TripContext? = nil
    
    var selectedFlight: FlightResult? = nil
    var selectedAccommodation: HotelResult? = nil
    
    func prewarmFlightAndAccommodationGenerator() {
        generatorFlightAndAccommodation = FlightAndAccommodationSuggestionGenerator()
        generatorFlightAndAccommodation!.prewarmModel()
    }
    
    var confirmFlightAndAccommodation: Bool {
        selectedFlight != nil && selectedAccommodation != nil
    }
    
    var selectedFlightAndAccommodation: SelectedOptions? {
        guard let selectedFlight, let selectedAccommodation else {
            return nil
        }
        return SelectedOptions(flight: selectedFlight, hotel: selectedAccommodation)
    }
}

