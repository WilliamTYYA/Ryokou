import FoundationModels
import SwiftUI

// MARK: - Hotel search

/// Arguments for `SearchHotelsTool`. Xotelo’s API supports searching by city
/// name. The check‑in and check‑out dates are required for rate calculation.
@Generable
public struct HotelSearchArguments: Codable {
    /// Name of the city or location to search for hotels (e.g. "Paris").
    public var query: String
    /// Check‑in date (YYYY‑MM‑DD).
    public var checkIn: String
    /// Check‑out date (YYYY‑MM‑DD).
    public var checkOut: String
    /// Maximum number of hotels to return. Defaults to 5.
    public var limit: Int?
    // Add an optional hotel budget
    public var maxPrice: Double?
}

/// A hotel result returned by `SearchHotelsTool`. Includes a name, an
/// approximate minimum and maximum price (derived from the API’s price range),
/// and optional coordinates for mapping.
@Generable
public struct HotelResult: Codable {
    public var name: String
    public var minimumPrice: Double?
    public var maximumPrice: Double?
    public var latitude: Double?
    public var longitude: Double?
}

/// A tool that searches for hotels via the Xotelo free hotel prices API. The
/// tool first searches for hotels matching the query and then retrieves price
/// ranges. Xotelo provides real‑time hotel price data in JSON format and
/// multiple endpoints for search and listing【413347354916326†L40-L77】. Developers
/// can integrate these endpoints without cost【413347354916326†L40-L77】.
public struct SearchHotelsTool: Tool {
    public var name: String { "searchHotels" }
    
    public var description: String {
        return "Searches for hotels in a city using the Xotelo free hotel prices API and returns price ranges."
    }
    
    public typealias Arguments = HotelSearchArguments
    
    public func call(arguments: Arguments) async throws -> [HotelResult] {
        // Step 1: perform a search query to retrieve hotel keys and location keys
        // Example: https://data.xotelo.com/api/search?query=tokyo
        let searchURLString = "https://data.xotelo.com/api/search?query=\(arguments.query)"
        guard let searchURL = URL(string: searchURLString) else {
            throw URLError(.badURL)
        }
        let (searchData, _) = try await URLSession.shared.data(from: searchURL)
        struct SearchResponse: Decodable {
            struct Result: Decodable {
                struct Hotel: Decodable {
                    let hotelKey: String
                    let locationKey: String
                    let name: String
                }
                let list: [Hotel]
            }
            let result: Result
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let searchResponse = try decoder.decode(SearchResponse.self, from: searchData)
        // Limit the number of hotels to query for rates
        let hotelsToProcess = Array(searchResponse.result.list.prefix(arguments.limit ?? 5))
        var results: [HotelResult] = []
        // Step 2: for each hotel, request the rates endpoint to obtain prices
        for hotel in hotelsToProcess {
            // Build the rates endpoint request: https://data.xotelo.com/api/rates?hotel_key=...&chk_in=YYYY-MM-DD&chk_out=YYYY-MM-DD
            var comps = URLComponents(string: "https://data.xotelo.com/api/rates")!
            comps.queryItems = [
                URLQueryItem(name: "hotel_key", value: hotel.hotelKey),
                URLQueryItem(name: "chk_in", value: arguments.checkIn),
                URLQueryItem(name: "chk_out", value: arguments.checkOut)
            ]
            guard let ratesURL = comps.url else { continue }
            do {
                let (ratesData, _) = try await URLSession.shared.data(from: ratesURL)
                struct RatesResponse: Decodable {
                    struct RateResult: Decodable {
                        struct Rate: Decodable {
                            let code: String
                            let name: String
                            let rate: Double
                        }
                        let rates: [Rate]
                    }
                    let result: RateResult
                }
                let ratesResponse = try decoder.decode(RatesResponse.self, from: ratesData)
                let allRates = ratesResponse.result.rates.map { $0.rate }
                let minRate = allRates.min()
                let maxRate = allRates.max()
                if let maxPrice = arguments.maxPrice, minRate ?? 0.0 > maxPrice {
                    continue
                }
                // Create the hotel result
                results.append(HotelResult(
                    name: hotel.name,
                    minimumPrice: minRate,
                    maximumPrice: maxRate,
                    latitude: nil,
                    longitude: nil
                ))
            } catch {
                // If rate retrieval fails, include the hotel without price data
                results.append(HotelResult(name: hotel.name, minimumPrice: nil, maximumPrice: nil, latitude: nil, longitude: nil))
            }
        }
        return results
    }
}
