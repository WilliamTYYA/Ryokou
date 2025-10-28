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
//    let landmark: Landmark
    var selectedFlight: FlightResult?
    var selectedHotel: HotelResult?
    
//    init(landmark: Landmark) { self.landmark = landmark }
    
    var canConfirm: Bool { selectedFlight != nil && selectedHotel != nil }
}
