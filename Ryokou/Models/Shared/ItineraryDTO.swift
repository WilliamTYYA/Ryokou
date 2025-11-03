import SwiftData
import Foundation
import CoreLocation

// Use a lightweight DTO to persist the *content* of your generated itinerary.
// (Storing the PartiallyGenerated type directly is risky; this is stable.)
nonisolated struct ItineraryDTO: Codable, Equatable, Sendable {
    var title: String?
    var destinationName: String?
    var description: String?
    var rationale: String?
    var days: [DayPlanDTO]?
    
    struct DayPlanDTO: Codable, Equatable {
        var title: String?
        var subtitle: String?
        var destination: String?
        var activities: [ActivityDTO]?
    }
    struct ActivityDTO: Codable, Equatable {
        var type: String?
        var title: String?
        var description: String?
    }
}

// Helpers to convert from your PartiallyGenerated model to DTO
extension ItineraryDTO {
    init(_ itinerary: Itinerary.PartiallyGenerated) {
        title = itinerary.title
        destinationName = itinerary.destinationName
        description = itinerary.description
        rationale = itinerary.rationale
        days = itinerary.days?.map { day in
                .init(
                    title: day.title,
                    subtitle: day.subtitle,
                    destination: day.destination,
                    activities: day.activities?.map { a in
                            .init(type: a.type?.rawValue, title: a.title, description: a.description)
                    }
                )
        }
    }
}
