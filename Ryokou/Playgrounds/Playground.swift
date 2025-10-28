import Playgrounds
import FoundationModels

#Playground {
    let flightsTool = SearchFlightsTool()
    let hotelsTool = SearchHotelsTool()
    let restaurantsTool = SearchRestaurantsTool()
    let shoppingTool = SearchShoppingTool()
    
    let flightBudget: Double = 5000.0     // total budget for flights
    let hotelBudget: Double = 500.0      // per-night budget for hotels
    
    let instructions = Instructions {
        "You are a travel planner."
        "Use the `searchFlights` tool to find flight options within the flight budget."
        "Use the `searchHotels` tool to find hotels within the hotel budget in the destination city."
    }
    
    let selectionSession = LanguageModelSession(
        tools: [flightsTool, hotelsTool],
        instructions: instructions
    )
    
    let prompt = Prompt {
        "Plan a round‑trip from Chicago (ORD) to Paris (CDG), departing 2025‑12‑01 and returning 2025‑12‑04."
        "The flight budget is \(flightBudget) USD and the hotel budget is \(hotelBudget) USD."
        "Provide flight and hotel options."
    }
    
    // First model call – returns flight and hotel suggestions
    let selectionResponse = try await selectionSession.respond(
        to: prompt,
        generating: FlightAndAccommodationSuggestion.self
    )
    
    let inspectSession = selectionSession
    
    // Example selected items
    let chosenFlight = selectionResponse.content.flights[0]  // user’s choice
    let chosenHotel = selectionResponse.content.hotels[0]    // user’s choice
    
    // Build a new instructions object for the itinerary step
    let itineraryInstructions = Instructions {
        "Your job is to create an itinerary for the user."
        "Use the chosen flight \(chosenFlight.airline) \(chosenFlight.flightNumber) and hotel \(chosenHotel.name) as the basis for the itinerary."
        "Use the `searchRestaurants` and `searchShopping` tools to find dining and shopping near the hotel’s coordinates (latitude \(chosenHotel.latitude ?? 0), longitude \(chosenHotel.longitude ?? 0))."
    }
    
    let itinerarySession = LanguageModelSession(
        tools: [restaurantsTool, shoppingTool],
        instructions: itineraryInstructions
    )
    
    let itineraryPrompt = Prompt {
        "Generate a 3‑day itinerary for the trip from Chicago to Paris using the selected flight and hotel."
        "Give the itinerary a fun title, include a rationale, and fill out the `days` array with appropriate activities."
        "Here is an example of the desired format, but don't copy its content:"
        Itinerary.exampleTripToJapan
    }
    
    // Second model call – returns an Itinerary
    let itineraryResponse = try await itinerarySession.respond(
        to: itineraryPrompt,
        generating: Itinerary.self,
        includeSchemaInPrompt: false
    )
    
    let inspectItinerary = itineraryResponse
}
