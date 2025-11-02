import Playgrounds
import FoundationModels

#Playground {
    let flightsTool = SearchFlightsTool()
    let hotelsTool = SearchHotelsTool()
    let restaurantsTool = SearchRestaurantsTool()
    let shoppingTool = SearchShoppingTool()
    
    let flightBudget: Double = 5000.0     // total budget for flights
    let hotelBudget: Double = 1000.0      // per-night budget for hotels
    
    let instructions = Instructions {
        "Create an itinerary using the user’s provided flight and hotel information for the destination."
        "On the first day, you MUST include a flight and a hotel activity based on the user’s provided flight and hotel information."
        "Each day should include one sightseeing, one dining or shopping, and one lodging activity."
        
        "Use the `searchFlights` tool to find flight options within the flight budget unless an information is provided."
        "Use the `searchHotels` tool to find hotels within the hotel budget in the destination city unless an information is provided."
        "Always use the `searchRestaurants` tool to find restaurants for the dinning activity."
        "Always use the `searchShopping` tool to find the shopping activity."
    }
    
    let session = LanguageModelSession(
        tools: [flightsTool, hotelsTool, restaurantsTool, shoppingTool],
        instructions: instructions
    )
    
    let promptFlightAndAccommodation = Prompt {
        "Plan a round‑trip from Chicago (ORD) to Paris (CDG), departing 2025‑12‑01 and returning 2025‑12‑04."
        "The flight budget is \(flightBudget) USD and the hotel budget is \(hotelBudget) USD per night."
        "Provide flight and hotel options."
    }
    
    // First model call – returns flight and hotel suggestions
    let responseFlightAndHotel = try await session.respond(
        to: promptFlightAndAccommodation,
        generating: FlightAndHotelSuggestion.self
    )
    
    let _ = responseFlightAndHotel
    
    // Example selected items
    let chosenFlight = responseFlightAndHotel.content.flights[0]  // user’s choice
    let chosenHotel = responseFlightAndHotel.content.hotels[0]    // user’s choice
    
    // Build a new instructions object for the itinerary step
//    let instructions = Instructions {
//        "Your job is to create an itinerary for the user."
//        "Use the chosen flight \(chosenFlight.airline) \(chosenFlight.flightNumber) and hotel \(chosenHotel.name) as the basis for the itinerary."
//        "Use the `searchRestaurants` and `searchShopping` tools to find dining and shopping near the hotel’s coordinates (latitude \(chosenHotel.latitude ?? 0), longitude \(chosenHotel.longitude ?? 0))."
//    }
    
//    let session = LanguageModelSession(
//        tools: [restaurantsTool, shoppingTool],
//        instructions: instructions
//    )
    
    let dayCount = 4
    
    let promptItinerary = Prompt {
        "Generate a \(dayCount)-day itinerary in Paris using this chosen flight: \(chosenFlight.flightNumber!) and hotel: \(chosenHotel.name)."
        "Give the itinerary a fun title, include a rationale, and fill out the `days` array with appropriate activities."
        "Here is an example of the desired format, but don't copy its content:"
        Itinerary.exampleTripToJapan
    }
    
    // Second model call – returns an Itinerary
//    let responseItinerary = try await session.respond(
//        to: prompt,
//        generating: Itinerary.self,
//        includeSchemaInPrompt: false
//    )
    
//    let _ = itineraryResponse
    
    let responseItinerary = try await session.respond(
        to: promptItinerary,
        generating: Itinerary.self,
        includeSchemaInPrompt: false
    )
    
    let _ = responseItinerary
}
