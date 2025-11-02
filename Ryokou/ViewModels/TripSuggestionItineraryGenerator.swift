import FoundationModels
import Observation
import Foundation

@Observable
final class TripSuggestionItineraryGenerator {
    private var session: LanguageModelSession
    private(set) var suggestion: FlightAndHotelSuggestion.PartiallyGenerated?
    private(set) var itinerary: Itinerary.PartiallyGenerated?
    
    var tripContext: ModelContext?
    var error: Error?
    
    init() {
        let flightsTool = SearchFlightsTool()
        let hotelsTool  = SearchHotelsTool()
        let restaurantsTool = SearchRestaurantsTool()
        let shoppingTool = SearchShoppingTool()
        
        let instructions = Instructions {
            "Create an itinerary using the user’s provided flight and hotel information for the destination."
            "On the first day, you MUST include a flight and a hotel activity based on the user’s provided flight and hotel information."
            "Each day should include one sightseeing, one dining or shopping, and one lodging activity."
            
            "Use the `searchFlights` tool to find flight options within the flight budget unless an information is provided."
            "Use the `searchHotels` tool to find hotels within the hotel budget in the destination city unless an information is provided."
            "Always use the `searchRestaurants` tool to find restaurants for the dinning activity."
            "Always use the `searchShopping` tool to find the shopping activity."
        }
        
        self.session = LanguageModelSession(
            tools: [flightsTool, hotelsTool, restaurantsTool, shoppingTool],
            instructions: instructions
        )
    }
    
    func generateFlightAndHotelSuggestion(context: ModelContext) async {
        do {
            self.tripContext = context
            
            let prompt = Prompt {
                "Plan a round-trip from \(context.origin) to \(context.destination.name), departing \(context.departureDateISO) and returning \(context.returnDateISO)."
                "The flight budget is \(context.flightBudgetUSD) USD and the hotel budget is \(context.hotelBudgetUSD) USD per night."
                "Provide flight and hotel options."
            }
            
            let stream = session.streamResponse(
                to: prompt,
                generating: FlightAndHotelSuggestion.self
            )
            
            for try await partialResponse in stream {
                self.suggestion = partialResponse.content
            }
        } catch {
            Log.e("FlightAndAccommodationSuggestionGenerator", error.localizedDescription)
            self.error = error
        }
    }
    
    func generateItinerary(context: ModelContext) async {
        do {
            self.tripContext = context
            
            guard let selectedFlight = context.selectedFlight, let selectedHotel = context.selectedHotel else {
                return
            }
            
            let prompt = Prompt {
                "Generate a \(context.dayCount)-day itinerary in \(context.destination.name) using this chosen flight: \(selectedFlight.flightNumber!) and hotel: \(selectedHotel.name)."
                "Give the itinerary a fun title, include a rationale, and fill out the `days` array with appropriate activities."
                "Here is an example of the desired format, but don't copy its content:"
                Itinerary.exampleTripToJapan
            }
            
            let stream = session.streamResponse(
                to: prompt,
                generating: Itinerary.self
            )
            
            for try await partialResponse in stream {
                self.itinerary = partialResponse.content
            }
        } catch {
            Log.e("FlightAndAccommodationSuggestionGenerator", error.localizedDescription)
            self.error = error
        }
    }
    
    func prewarmModel() {
        session.prewarm()
    }
}
