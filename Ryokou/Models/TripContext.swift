//
//  TripContext.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Foundation
//import Calendar

struct TripContext: Equatable {
    let origin: String
    let destination: String
    let flightBudgetUSD: Double
    let hotelBudgetUSD: Double
    let departureDateISO: String   // "YYYY-MM-DD"
    let returnDateISO: String      // "YYYY-MM-DD"
}

extension TripContext {
    static let df: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    static func from(profile: Profile, landmark: Destination, departureDate: Date, returnDate: Date) -> TripContext {
        TripContext(
            origin: profile.location.city,
            destination: landmark.name,
            flightBudgetUSD: profile.flightBudgetUSD,
            hotelBudgetUSD: profile.hotelBudgetUSD,
            departureDateISO: df.string(from: departureDate),
            returnDateISO: df.string(from: returnDate)
        )
    }
}
