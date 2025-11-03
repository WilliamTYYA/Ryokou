//
//  TripPlan.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 11/2/25.
//

import SwiftData
import Foundation

// MARK: - SwiftData entity
@Model
final class TripPlan {
    #Index<TripPlan>([\.destinationName], [\.isFavorite], [\.departureDate], [\.destinationName, \.isFavorite, \.departureDate])
    #Unique<TripPlan>([\.destinationID, \.departureDate, \.returnDate])
    
    var createdAt: Date = Date()
    var isFavorite: Bool = false
    
    // Context
    var origin: String
    var destinationID: String
    var destinationName: String
    var departureDate: Date
    var returnDate: Date
    var flightBudgetUSD: Double
    var hotelBudgetUSD: Double
    
    // User choices + generated content (stored as Data)
    @Attribute(.externalStorage) var selectedFlightData: Data?
    @Attribute(.externalStorage) var selectedHotelData: Data?
    @Attribute(.externalStorage) var itineraryData: Data?
    
    init(
        key: String,
         origin: String,
         destinationID: String,
         destinationName: String,
         departureDate: Date,
         returnDate: Date,
         flightBudgetUSD: Double,
         hotelBudgetUSD: Double
    )
    {
        self.origin = origin
        self.destinationID = destinationID
        self.destinationName = destinationName
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.flightBudgetUSD = flightBudgetUSD
        self.hotelBudgetUSD = hotelBudgetUSD
    }
}

// Computed helpers to read/write Codable blobs
extension TripPlan {
    var selectedFlight: FlightResult? {
        get { decode(FlightResult.self, from: selectedFlightData) }
        set { selectedFlightData = encode(newValue) }
    }
    var selectedHotel: HotelResult? {
        get { decode(HotelResult.self, from: selectedHotelData) }
        set { selectedHotelData = encode(newValue) }
    }
//    var itinerary: ItineraryDTO? {
//        get { decode(ItineraryDTO.self, from: itineraryData) }
//        set { itineraryData = encode(newValue) }
//    }
    var itinerary: Itinerary? {
        get { decode(Itinerary.self, from: itineraryData) }
        set { itineraryData = encode(newValue) }
    }
    
    private func encode<T: Encodable>(_ value: T?) -> Data? {
        guard let value else { return nil }
        return try? JSONEncoder().encode(value)
    }
    private func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
