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
        "Always use the 'searchFlights' tool to find flights from origin to destination within budget"
        "Always use the 'searchHotels' tool to find hotels in the destination city within budget"
        "Always Use 'searchRestaurants' tool to recommend restaurants."
        "Always Use 'searchShopping' tool to recommend shopping malls."
    }
    
    let session = LanguageModelSession(
        tools: [flightsTool, hotelsTool, restaurantsTool, shoppingTool],
        instructions: instructions
    )
    
    let prompt = Prompt {
        "Plan a round‑trip from Chicago (ORD) to Paris (CDG), departing 2025‑12‑01 and returning 2025‑12‑04."
        "The flight budget is \(flightBudget) USD and the hotel budget is \(hotelBudget) USD per night."
        "Provide flight, hotel, restaurants and shopping mall options."
    }
    
    let suggestion = try await session.respond(
        to: prompt,
        generating: TripSuggestion.self,
    )
    
    let inspectSession = session
}
