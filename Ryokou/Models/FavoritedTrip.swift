//
//  Trip.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import Foundation
import SwiftData

// MARK: - Data Models

/// A simple model representing a saved trip. In a real application this
/// would contain rich structured data for each component of the trip, but
/// for demonstration purposes we keep it simple.
@Model
final class FavoritedTrip {
    var id: UUID
    var title: String
    var destination: String
    var summary: String
    
    init(title: String, destination: String, summary: String) {
        self.id = UUID()
        self.title = title
        self.destination = destination
        self.summary = summary
    }
}
