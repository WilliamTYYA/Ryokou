//
//  Landmark.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Foundation
import MapKit

struct Destination: Hashable, Codable, Identifiable {
    var id: String            // same as background image name
    var name: String
    var continent: String
    var description: String
    var latitude: Double
    var longitude: Double
    var span: Double          // map zoom delta (≈0.1–0.3 works well for cities)
    
    var backgroundImageName: String { id }
    var thumbnailImageName: String { "\(id)-thumb" }
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: locationCoordinate,
            span: .init(latitudeDelta: span, longitudeDelta: span)
        )
    }
}

// MARK: - Sample Data

enum ModelData {
    static let destinations: [Destination] = [
        Destination(
            id: "Paris",
            name: "Paris",
            continent: "Europe",
            description: "City of Light along the Seine — home to the Eiffel Tower, Louvre, and café culture.",
            latitude: 48.8566,
            longitude: 2.3522,
            span: 0.2
        ),
        Destination(
            id: "NewYork",
            name: "New York",
            continent: "North America",
            description: "The Big Apple — Manhattan skyline, Central Park, world-class arts and food.",
            latitude: 40.7128,
            longitude: -74.0060,
            span: 0.22
        ),
        Destination(
            id: "Tokyo",
            name: "Tokyo",
            continent: "Asia",
            description: "Vast, electric metropolis — shrines and skyscrapers, sushi and street fashion.",
            latitude: 35.6762,
            longitude: 139.6503,
            span: 0.22
        )
    ]
    
    static let destinationNames: [String] = destinations.map { $0.name }
}
