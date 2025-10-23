import FoundationModels
import SwiftUI

// MARK: - Restaurant search

/// Arguments for `SearchRestaurantsTool`. Provide a latitude/longitude pair and
/// optionally a search radius in metres (defaults to 5000 m). The API returns
/// restaurants near the specified point.
@Generable
public struct RestaurantSearchArguments: Codable {
    /// Latitude of the centre point.
    public var latitude: Double
    /// Longitude of the centre point.
    public var longitude: Double
    /// Radius in metres for the search area (defaults to 5000 if nil).
    public var radius: Double?
    /// Maximum number of restaurants to return (defaults to 10).
    public var limit: Int?
}

/// A restaurant result returned by `SearchRestaurantsTool`.
@Generable
public struct RestaurantResult: Codable {
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
    public var distance: Double?
}

/// Searches for restaurants near a given coordinate using the Geoapify Places
/// API. The Places API supports over 500 categories of points of interest and
/// allows querying by category within a radius or bounding box【876352476334005†L276-L284】.
/// Geoapify offers a free tier with up to 3000 requests per day and the API
/// requires only an API key【876352476334005†L304-L307】. Restaurants fall under
/// the `catering.restaurant` category【876352476334005†L598-L634】.
public struct SearchRestaurantsTool: Tool {
    public var name: String { "searchRestaurants" }
    
    public var description: String {
        return "Finds nearby restaurants around a coordinate using the Geoapify Places API."
    }
    
    public typealias Arguments = RestaurantSearchArguments
    
    public func call(arguments: Arguments) async throws -> [RestaurantResult] {
        // Provide defaults
        let radius = arguments.radius ?? 5000.0
        let limit = arguments.limit ?? 10
        // Compose the API URL: https://api.geoapify.com/v2/places?categories=catering.restaurant&filter=circle:lon,lat,radius&limit=limit&apiKey=...
        var comps = URLComponents(string: "https://api.geoapify.com/v2/places")!
        comps.queryItems = [
            URLQueryItem(name: "categories", value: "catering.restaurant"),
            URLQueryItem(name: "filter", value: "circle:\(arguments.longitude),\(arguments.latitude),\(radius)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "apiKey", value: APIKeys.geoapifyAPIKey)
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        // Define local response structures
        struct PlacesResponse: Decodable {
            struct Feature: Decodable {
                struct Properties: Decodable {
                    let name: String?
                    let addressLine1: String?
                    let lat: Double
                    let lon: Double
                    let distance: Double?
                }
                let properties: Properties
            }
            let features: [Feature]
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let places = try decoder.decode(PlacesResponse.self, from: data)
        // Map features into RestaurantResult
        let results = places.features.compactMap { feature -> RestaurantResult? in
            guard let name = feature.properties.name, let address = feature.properties.addressLine1 else { return nil }
            return RestaurantResult(
                name: name,
                address: address,
                latitude: feature.properties.lat,
                longitude: feature.properties.lon,
                distance: feature.properties.distance
            )
        }
        return results
    }
}
