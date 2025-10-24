/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that generates an itinerary.
*/

import FoundationModels
import Observation

@Observable
@MainActor
final class ItineraryGenerator {
    
    var error: Error?
    let landmark: Landmark
    
    // MARK: - [CODE-ALONG] Chapter 1.5.1: Add a session property
    private var session: LanguageModelSession
    
    // MARK: - [CODE-ALONG] Chapter 4.1.1: Change the property to hold a partially generated Itinerary
    private(set) var itinerary: Itinerary.PartiallyGenerated?

    init(landmark: Landmark) {
        self.landmark = landmark
        
        // MARK: - [CODE-ALONG] Chapter 5.3.1: Update the instructions to use the Tool
        let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)
        let instructions = Instructions {
            "Your job is to create an itinerary for the user."
            "For each day, you must suggest one hotel and one restaurant."
            "Always use the 'findPointsOfInterest' tool to find hotels and restaurant in \(landmark.name)"
        }
        self.session = LanguageModelSession(
            tools: [pointOfInterestTool],
            instructions: instructions
        )
    }

    func generateItinerary(dayCount: Int = 3) async {
        do {
            // MARK: - [CODE-ALONG] Chapter 3.3: Update to use one-shot prompting
            let prompt = Prompt {
                "Generate a \(dayCount)-day itinerary to \(landmark.name)."
                "Give it a fun title and description."
                "Here is an example of the desired format, but don't copy its content:"
                Itinerary.exampleTripToJapan
            }
            
            // MARK: - [CODE-ALONG] Chapter 5.3.3: Update `session.streamResponse` to include greedy sampling
            let stream = session.streamResponse(
                to: prompt,
                generating: Itinerary.self,
                includeSchemaInPrompt: false,
                options: GenerationOptions(sampling: .greedy)
            )
            for try await partialResponse in stream {
                self.itinerary = partialResponse.content
            }
        } catch {
            self.error = error
        }
    }

    func prewarmModel() {
        // MARK: - [CODE-ALONG] Chapter 6.1.1: Add a function to pre-warm the model
        session.prewarm(promptPrefix: Prompt {
            "Generate 3-day itinerary to \(landmark.name)."
        })
    }
}
