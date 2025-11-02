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
    
    func prewarmFlightAndAccommodationGenerator() {
        generatorFlightAndAccommodation = FlightAndAccommodationSuggestionGenerator()
        generatorFlightAndAccommodation!.prewarmModel()
    }
    
    var confirmFlightAndAccommodation: Bool {
        selectedFlight != nil && selectedHotel != nil
    }
    
    var tripContext: ModelContext? = nil
    
    var selectedFlight: FlightResult? { tripContext?.selectedFlight }
    var selectedHotel: HotelResult? { tripContext?.selectedHotel }
    
    func setSelectedFlight(_ result: FlightResult) {
        tripContext?.selectedFlight = result
    }
    
    func setSelectedHotel(_ result: HotelResult) {
        tripContext?.selectedHotel = result
    }
}

