import FoundationModels
import SwiftUI

@Generable
public struct HotelSearchArguments: Codable {
    /// e.g. "Paris"
    @Guide(description: "A city name, e.g. Paris")
    public var query: String
    /// Check‑in date (YYYY‑MM‑DD).
    @Guide(description: "Check in date in YYYY‑MM‑DD format")
    public var checkIn: String
    @Guide(description: "Check out date in YYYY‑MM‑DD format")
    public var checkOut: String
    /// Maximum number of hotels to return. Defaults to 5.
    public var limit: Int = 3
    @Guide(description: "Hotel budget in USD per night")
    public var budget: Double
}


@Generable
public struct HotelResult: Codable {
    public var name: String
    public var minimumPrice: Double?
    public var maximumPrice: Double?
}

@Observable
public final class SearchHotelsTool: Tool {
    public let name: String = "searchHotels"
    
    public let description: String = "Searches for hotels in a city using the Xotelo free hotel prices API and returns price ranges."
    
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
        
        let hotelsToProcess = Array(searchResponse.result.list.prefix(arguments.limit))
        var results: [HotelResult] = []
        
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
                
                if minRate ?? 0.0 > arguments.budget {
                    continue
                }
                
                // Create the hotel result
                results.append(HotelResult(
                    name: hotel.name,
                    minimumPrice: minRate,
                    maximumPrice: maxRate,
                ))
            } catch {
                // If rate retrieval fails, include the hotel without price data
                results.append(HotelResult(name: hotel.name))
            }
        }
        return results
    }
}
