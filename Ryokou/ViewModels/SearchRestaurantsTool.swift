import FoundationModels
import SwiftUI

@Generable
public struct RestaurantSearchArguments: Codable {
    public var latitude: Double
    public var longitude: Double
    public var radius: Double?
    public var limit: Int?
}

@Generable
public struct RestaurantResult: Codable {
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
    public var distance: Double?
}

public struct SearchRestaurantsTool: Tool {
    public let name: String = "searchRestaurants"
    
    public let description: String = "Finds nearby restaurants around a coordinate using the Geoapify Places API."
    
    public typealias Arguments = RestaurantSearchArguments
    
    public func call(arguments: Arguments) async throws -> [RestaurantResult] {
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
