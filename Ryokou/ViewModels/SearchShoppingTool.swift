import FoundationModels
import SwiftUI

// MARK: - Shopping mall search

/// Arguments for `SearchShoppingTool`. Similar to restaurants but targeting
/// shopping centres.
@Generable
public struct ShoppingSearchArguments: Codable {
    public var latitude: Double
    public var longitude: Double
    public var radius: Double?
    public var limit: Int?
}

/// A shopping venue result. Contains the name, address and optional distance.
@Generable
public struct ShoppingResult: Codable {
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
    public var distance: Double?
}

/// Searches for shopping malls and other retail complexes using Geoapify. The
/// category `commercial.shopping_mall` identifies malls in Geoapify’s
/// hierarchical category system【876352476334005†L430-L499】. Like restaurants,
/// the Places API query uses a circular filter around a coordinate.
public struct SearchShoppingTool: Tool {
    public var name: String { "searchShopping" }
    
    public var description: String {
        return "Finds nearby shopping malls around a coordinate using the Geoapify Places API."
    }
    
    public typealias Arguments = ShoppingSearchArguments
    
    public func call(arguments: Arguments) async throws -> [ShoppingResult] {
        let radius = arguments.radius ?? 5000.0
        let limit = arguments.limit ?? 10
        var comps = URLComponents(string: "https://api.geoapify.com/v2/places")!
        comps.queryItems = [
            URLQueryItem(name: "categories", value: "commercial.shopping_mall"),
            URLQueryItem(name: "filter", value: "circle:\(arguments.longitude),\(arguments.latitude),\(radius)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "apiKey", value: APIKeys.geoapifyAPIKey)
        ]
        guard let url = comps.url else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
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
        let results = places.features.compactMap { feature -> ShoppingResult? in
            guard let name = feature.properties.name, let address = feature.properties.addressLine1 else { return nil }
            return ShoppingResult(
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
