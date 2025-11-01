//
//  GeneratorRoute.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import Foundation

enum TripPlanRoute: Hashable {
    case destination(Destination)
    case suggestions
    case itinerary
}

struct SelectedOptions: Hashable {
    let flight: FlightResult
    let hotel: HotelResult
}
