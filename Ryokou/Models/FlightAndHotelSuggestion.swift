//
//  TripSuggestion.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import Foundation
import FoundationModels

// MARK: - Trip suggestion model

@Generable
public struct FlightAndHotelSuggestion: Codable, Equatable {
    @Guide(.count(3))
    public var flights: [FlightResult]
    @Guide(.count(3))
    public var hotels: [HotelResult]
//    @Guide(.count(3))
//    public var restaurants: [RestaurantResult]
//    @Guide(.count(3))
//    public var shoppings: [ShoppingResult]
}

// MARK: - Environment

nonisolated public enum APIKeys {
    public static let geoapifyAPIKey: String = "74b4b4800b9643279ca273f4fe0ad55c"
    public static let flightAPIKey: String = "68fa949ccb4194c88bffca9a"
}

