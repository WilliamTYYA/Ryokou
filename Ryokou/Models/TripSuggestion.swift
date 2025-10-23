//
//  TripSuggestion.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import Foundation
import FoundationModels

// MARK: - Trip suggestion model

/// An aggregate suggestion for a trip. When the language model finishes
/// querying all four tools, it can pack the results into this structure for
/// presentation to the user. Because it conforms to `@Generable`, the model
/// will know how to fill in the fields properly.
@Generable
public struct TripSuggestion: Codable {
    public var flights: [FlightResult]
    public var hotels: [HotelResult]
    public var restaurants: [RestaurantResult]
    public var shopping: [ShoppingResult]
}

// MARK: - Environment

/// A helper type that stores API keys. In a real app you would load these
/// values from secure storage or configuration rather than hard‑coding them.
public enum APIKeys {
    /// Your Skyscanner API key. Obtain one from the Skyscanner Partners
    /// programme. The travelpayouts article notes that the Skyscanner Flights
    /// API is free and provides real‑time price updates【843647540575323†L377-L385】.
    public static let skyscannerAPIKey: String = "YOUR_SKYSCANNER_API_KEY"
    /// Your Geoapify API key. Geoapify offers up to 3000 requests per day on
    /// their free plan【876352476334005†L304-L307】.
    public static let geoapifyAPIKey: String = "74b4b4800b9643279ca273f4fe0ad55c"
    
    /// Your FlightAPI.io key. Register for a free trial on the FlightAPI
    /// website to obtain this key. Their free tier includes 30 days of
    /// access with 20 credits and no credit card required【481725670650509†L60-L71】.
    public static let flightAPIKey: String = "68fa949ccb4194c88bffca9a"
}

