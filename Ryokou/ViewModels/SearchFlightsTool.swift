import FoundationModels
import SwiftUI

// MARK: - Flight search

/// Arguments for `SearchFlightsTool`. When the model needs to find flights it
/// will populate an instance of this type. All properties are strings to
/// simplify serialization. Dates should be provided in the format `YYYY-MM-DD`.
@Generable
public struct FlightSearchArguments: Codable {
    /// IATA code of the origin airport or city (e.g. "LAX" for Los Angeles).
    public var origin: String
    /// IATA code of the destination airport or city (e.g. "JFK" for New York).
    public var destination: String
    /// Departure date in ISO 8601 calendar date format.
    public var departureDate: String
    /// Optional return date for round‑trip itineraries. If omitted, a one‑way
    /// trip is assumed.
    public var returnDate: String?
    /// Number of adult passengers travelling.
    public var adults: Int
    /// ISO 4217 currency code for price results (e.g. "USD"). Defaults to
    /// "USD" if left blank.
    public var currency: String?
    /// Market where the search originates (e.g. "US" or "GB"). Defaults to
    /// "US" if left blank.
    public var market: String?
    /// Locale specifying the language of the results (e.g. "en-US"). Defaults
    /// to "en-US" if left blank.
    public var locale: String?
    // Add an optional flight budget
    public var maxPrice: Double?
}

/// A single flight option returned by `SearchFlightsTool`. This structure is
/// simplified relative to Skyscanner’s full response; you can extend it with
/// additional fields such as number of stops or airline name as needed. The
/// language model can inspect these properties to summarise or compare
/// itineraries.
@Generable
public struct FlightResult: Codable {
    /// Name of the airline operating the flight (e.g. "Delta").
    public var airline: String
    /// Flight number assigned by the airline (e.g. "DL 1234").
    public var flightNumber: String
    /// Total price for the itinerary in the requested currency.
    public var price: Double
    /// ISO 4217 currency code used for the `price` field.
    public var currency: String
    /// Date and time of departure in ISO 8601 format.
    public var departureTime: String
    /// Date and time of arrival in ISO 8601 format.
    public var arrivalTime: String
}

/// A tool that searches for flights using the Skyscanner Browse Quotes API.
///
/// Skyscanner’s Flights API allows developers to query indicative flight
/// prices by providing an origin, destination and travel dates. The API is free
/// to use but requires an API key; travellers can search for flights from
/// anywhere with real‑time price updates, and request limits are generous on
/// the browse endpoints【843647540575323†L377-L385】. This tool uses the
/// “browsequotes” endpoint because it’s simpler than the live pricing workflow.
public struct SearchFlightsTool: Tool {
    public var name: String { "searchFlights" }
    
    public var description: String {
        return "Searches for flights between an origin and destination using the FlightAPI.io Flight Price API."
    }
    
    /// Parameters for the tool call defined by the language model. See
    /// `FlightSearchArguments` above. Conforms to `@Generable` so the model
    /// knows how to populate the fields.
    public typealias Arguments = FlightSearchArguments
    
    /// Executes the flight search and returns a list of flight options.
    ///
    /// This implementation uses the FlightAPI.io Flight Price API. It
    /// automatically selects the one‑way or round‑trip endpoint based on
    /// whether a `returnDate` is provided. The API expects path parameters in
    /// the following order:
    ///
    /// - apiKey: Your FlightAPI.io key
    /// - departure airport IATA code
    /// - arrival airport IATA code
    /// - departure date (YYYY‑MM‑DD)
    /// - return/arrival date (for round‑trip only)
    /// - number of adults
    /// - number of children (set to 0)
    /// - number of infants (set to 0)
    /// - cabin class (we default to "Economy")
    /// - currency (ISO 4217)
    ///
    /// The response JSON includes an `itineraries` array and a `legs` array. To
    /// build a simplified `FlightResult`, this method extracts the first
    /// pricing option’s amount for each itinerary and matches the leg by ID
    /// to obtain departure and arrival timestamps. Airline and flight number
    /// fields are left empty because FlightAPI does not provide carrier
    /// names in the primary response.
    public func call(arguments: Arguments) async throws -> [FlightResult] {
        // Provide sensible defaults
        let currency = arguments.currency ?? "USD"
        let adults = arguments.adults
        // Set default counts for children and infants (not supported by the
        // current arguments structure)
        let children = 0
        let infants = 0
        let cabinClass = "Economy"
        
        // Build the base path depending on whether this is one‑way or round‑trip
        let apiKey = APIKeys.flightAPIKey
        let origin = arguments.origin
        let destination = arguments.destination
        let departureDate = arguments.departureDate
        var urlString: String
        if let returnDate = arguments.returnDate, !returnDate.isEmpty {
            // Round trip
            // Endpoint: /roundtrip/<apiKey>/<origin>/<destination>/<departureDate>/<returnDate>/<adults>/<children>/<infants>/<cabinClass>/<currency>
            urlString = "https://api.flightapi.io/roundtrip/\(apiKey)/\(origin)/\(destination)/\(departureDate)/\(returnDate)/\(adults)/\(children)/\(infants)/\(cabinClass)/\(currency)"
        } else {
            // One‑way
            // Endpoint: /onewaytrip/<apiKey>/<origin>/<destination>/<departureDate>/<adults>/<children>/<infants>/<cabinClass>/<currency>
            urlString = "https://api.flightapi.io/onewaytrip/\(apiKey)/\(origin)/\(destination)/\(departureDate)/\(adults)/\(children)/\(infants)/\(cabinClass)/\(currency)"
        }
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON response. The structure includes itineraries and legs.
        struct FlightAPIResponse: Decodable {
            struct Itinerary: Decodable {
                let id: String
                let legIds: [String]?
                let pricingOptions: [PricingOption]?
            }
            struct PricingOption: Decodable {
                struct Price: Decodable {
                    let amount: Double
                }
                let price: Price
            }
            struct Leg: Decodable {
                let id: String
                let departure: String
                let arrival: String
            }
            let itineraries: [Itinerary]
            let legs: [Leg]
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(FlightAPIResponse.self, from: data)
        // Build a lookup of legs by ID for quick access
        let legLookup = Dictionary(uniqueKeysWithValues: apiResponse.legs.map { ($0.id, $0) })
        // Map itineraries to FlightResult
        var results: [FlightResult] = []
        for itinerary in apiResponse.itineraries {
            // Extract price
            guard let pricingOption = itinerary.pricingOptions?.first else { continue }
            let price = pricingOption.price.amount
            if let maxPrice = arguments.maxPrice, price > maxPrice {
                continue
            }
            // Match the first leg to get departure and arrival times
            var departureTime = ""
            var arrivalTime = ""
            if let legId = itinerary.legIds?.first, let leg = legLookup[legId] {
                departureTime = leg.departure
                arrivalTime = leg.arrival
            }
            results.append(FlightResult(
                airline: "",
                flightNumber: "",
                price: price,
                currency: currency,
                departureTime: departureTime,
                arrivalTime: arrivalTime
            ))
        }
        return results
    }
}
