/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A class that generates an itinerary.
 */

import FoundationModels
import Observation
import Foundation

@Observable
final class FlightAndAccommodationSuggestionGenerator {
    private var session: LanguageModelSession
    private(set) var suggestion: FlightAndAccommodationSuggestion.PartiallyGenerated?
    
    var tripContext: TripContext?
    var error: Error?
    
    init() {
        let flightsTool = SearchFlightsTool()
        let hotelsTool  = SearchHotelsTool()
        
        let instructions = Instructions {
            "You are a travel planner."
            "Use the `searchFlights` tool to find flight options within the flight budget."
            "Use the `searchHotels` tool to find hotels within the hotel budget in the destination city."
        }
        
        self.session = LanguageModelSession(
            tools: [flightsTool, hotelsTool],
            instructions: instructions
        )
    }
    
    func generateTripSuggestion(context: TripContext) async {
        do {
            self.tripContext = context
            /**
             let prompt = Prompt {
             "Plan a round‑trip from Chicago (ORD) to Paris (CDG), departing 2025‑12‑01 and returning 2025‑12‑04."
             "The flight budget is \(flightBudget) USD and the hotel budget is \(hotelBudget) USD per night."
             "Provide flight and hotel options."
             }
             */
            let prompt = Prompt {
                "Plan a round-trip from \(context.origin) to \(context.destination), departing \(context.departureDateISO) and returning \(context.returnDateISO)."
                "The flight budget is \(context.flightBudgetUSD) USD and the hotel budget is \(context.hotelBudgetUSD) USD per night."
                "Provide flight and hotel options."
            }
            
            let stream = session.streamResponse(
                to: prompt,
                generating: FlightAndAccommodationSuggestion.self
            )
            
            for try await partialResponse in stream {
                self.suggestion = partialResponse.content
            }
        } catch {
            Log.e("FlightAndAccommodationSuggestionGenerator", error.localizedDescription)
            self.error = error
        }
    }
    
    func resetSuggestion() {
        Log.i("FlightAndAccommodationSuggestionGenerator", "resetSuggestion")
        suggestion = nil
    }
    
    func prewarmModel() {
        session.prewarm()
    }
}
