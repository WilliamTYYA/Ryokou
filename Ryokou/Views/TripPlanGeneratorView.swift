import SwiftUI

struct TripPlanGeneratorView: View {
    let landmark: Landmark
    
    @State private var flightAndAccommodationSuggestionGenerator: FlightAndAccommodationSuggestionGenerator?
    @State private var flightAndAccommodationSuggestionViewModel: FlightAndAccommodationSuggestionViewModel = .init()

    @AppStorage("profile") private var profile: Profile = .sample
    @State private var requestedItinerary: Bool = false
    
    @State private var departure = Date()
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
                    
                    DateRangeFields(departure: $departure,
                                    returning: $returning,
                                    earliest: Date(),
                                    latest: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
                                    minimumNights: 1)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let flightAndAccommodationSuggestion = flightAndAccommodationSuggestionGenerator?.suggestion {
                FlightAndAccomodationSuggestionView(
                    viewModel: flightAndAccommodationSuggestionViewModel,
                    suggestion: flightAndAccommodationSuggestion
                )
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
                await flightAndAccommodationSuggestionGenerator?.generateTripSuggestion(context: ctx)
            }
        }
        .task {
            let generator = FlightAndAccommodationSuggestionGenerator()
            self.flightAndAccommodationSuggestionGenerator = generator
            
            generator.prewarmModel()
        }
        .headerStyle(landmark: landmark)
    }
    
}
