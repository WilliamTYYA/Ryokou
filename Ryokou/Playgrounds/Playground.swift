// This Swift Playground demonstrates how to use the travel planning tools
// defined in `FoundationTripTools.swift`. It constructs a language model
// session with our search tools and asks the model to generate a trip
// suggestion. The session is configured with instructions that tell the
// model which tools to call and what the output should look like. Replace
// the origin, destination, dates and API keys with your own values.

import Playgrounds
import FoundationModels

// NOTE: Before running this playground, ensure that your API keys are set
// appropriately in the `Environment` struct of `FoundationTripTools.swift`.

#Playground {
    // Create instances of each tool. No arguments are needed at
    // construction time because the language model will provide them.
    let flightsTool = SearchFlightsTool()
    let hotelsTool = SearchHotelsTool()
    let restaurantsTool = SearchRestaurantsTool()
    let shoppingTool = SearchShoppingTool()
    
    let flightBudget: Double = 800.0     // total budget for flights
    let hotelBudget: Double = 200.0      // per-night budget for hotels
    
    // Provide high‑level instructions to the language model. These
    // instructions describe the assistant’s role and explicitly list the
    // available tools. The model will decide which tool to call based on
    // user input.
    let instructions = Instructions {
        "You are a travel planner. Your job is to create a trip plan for the user."
        "Use 'searchFlights' tool with 'maxPrice' of \(flightBudget) to find flight options within budget."
        "Use 'searchHotels' tool with 'maxPrice' of \(hotelBudget) to recommend hotels within budget."
        "Use 'searchRestaurants' tool to recommend restaurants."
        "Use 'searchShopping' tool to suggest shopping venues."
        "Return only results whose prices are within those budgets."
    }
    // "Return your results in a 'TripSuggestion' structure."
    
    // Assemble the language model session with our tools and instructions.
    let session = LanguageModelSession(
        tools: [flightsTool, hotelsTool, restaurantsTool, shoppingTool],
        instructions: instructions
    )
    
    // Compose the user prompt. You can customise the origin, destination
    // and trip duration as needed. The model will invoke the tools
    // automatically to fulfil the request.
    let prompt = Prompt {
        "Plan a 3‑day trip from Chicago (ORD) to Paris (CDG) departing on 2025‑05‑01."
        "The flight budget is \(flightBudget) USD and the hotel budget is \(hotelBudget) USD per night."
        "Provide flight options, hotel suggestions, restaurant recommendations and shopping activities."
        "Give the trip a fun title and description."
    }
    
    // Ask the language model to respond and decode the response into a
    // TripSuggestion. GenerationOptions can be customised (e.g. to use
    // greedy or sampling‑based decoding). You must call this inside an
    // asynchronous context because network calls are involved.
    let suggestion = try await session.respond(
        to: prompt,
        generating: TripSuggestion.self,
//        options: GenerationOptions(sampling: .greedy)
    )
    
    // At this point `suggestion` contains the structured trip plan. You can
    // inspect the session transcript for debugging or display the results
    // however you like.
    let inspectSession = session
}
