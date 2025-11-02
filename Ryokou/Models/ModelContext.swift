//
//  TripContext.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Foundation
//import Calendar

struct ModelContext: Equatable, Hashable {
    let origin: String
    let destination: Destination
    let flightBudgetUSD: Double
    let hotelBudgetUSD: Double
    let departureDateISO: String   // "YYYY-MM-DD"
    let returnDateISO: String      // "YYYY-MM-DD"
    var selectedFlight: FlightResult? = nil
    var selectedHotel: HotelResult? = nil
}

extension ModelContext {
    static let df: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    static func from(profile: Profile, destination: Destination, departureDate: Date, returnDate: Date) -> ModelContext {
        ModelContext(
            origin: profile.location.city,
            destination: destination,
            flightBudgetUSD: profile.flightBudgetUSD,
            hotelBudgetUSD: profile.hotelBudgetUSD,
            departureDateISO: df.string(from: departureDate),
            returnDateISO: df.string(from: returnDate)
        )
    }
    
    /// Number of **nights** between departure and return (e.g. 2025-12-01 → 2025-12-04 = 3)
    var dayCount: Int {
        guard
            let start = Self.df.date(from: departureDateISO),
            let end   = Self.df.date(from: returnDateISO)
        else { return 0 }
        
        let cal = Calendar(identifier: .gregorian)
        let startDay = cal.startOfDay(for: start)
        let endDay   = cal.startOfDay(for: end)
        let diff = cal.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        /// diff is Number of **nights**
        return diff + 1
    }
}
