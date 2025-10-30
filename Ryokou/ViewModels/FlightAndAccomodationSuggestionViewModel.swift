//
//  TripSuggestionViewModel.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Observation

@Observable
@MainActor
final class FlightAndAccommodationSuggestionViewModel {
    var selectedFlight: FlightResult?
    var selectedHotel: HotelResult?
        
    var canConfirm: Bool { selectedFlight != nil && selectedHotel != nil }
}
