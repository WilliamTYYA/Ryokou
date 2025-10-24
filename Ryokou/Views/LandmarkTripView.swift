import SwiftUI

struct LandmarkTripView: View {
    let landmark: Landmark
    
    @State private var tripSuggestionGenerator: TripSuggestionGenerator?

    @AppStorage("profile") private var profile: Profile = .sample
    @State private var requestedItinerary: Bool = false
    
    @State private var departure = Date()                  // bind to your date pickers
    @State private var returning = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    
    var body: some View {
        ScrollView {
            if !requestedItinerary {
                VStack(alignment: .leading, spacing: 16) {
                    Text(landmark.name)
                        .padding(.top, 150)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(landmark.description)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let itinerary = tripSuggestionGenerator?.tripSuggestion {
//                ItineraryView(landmark: landmark, itinerary: itinerary)
//                    .padding()
            }
            
        }
        .scrollDisabled(!requestedItinerary)
        .safeAreaInset(edge: .bottom) {
            GenerateButton(label: "Options") {
                requestedItinerary = true
                let ctx = TripContext.from(profile: profile,
                                           landmark: landmark,
                                           departureDate: departure,
                                           returnDate: returning)
                await tripSuggestionGenerator?.generateTripSuggestion(context: ctx)
            }
        }
        .task {
            let generator = TripSuggestionGenerator()
            self.tripSuggestionGenerator = generator
            
            generator.prewarmModel()
        }
        .headerStyle(landmark: landmark)
    }
    
}
