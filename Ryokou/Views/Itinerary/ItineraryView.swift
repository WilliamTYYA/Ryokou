import FoundationModels
import SwiftUI
import MapKit

struct ItineraryView: View {
    private let itinerary: Itinerary.PartiallyGenerated
    
    init(itinerary: Itinerary.PartiallyGenerated) {
        self.itinerary = itinerary
    }
    
    @Environment(TripPlanViewModel.self) private var tripPlanViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                if let title = itinerary.title {
                    Text(title)
                        .contentTransition(.opacity)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                if let description = itinerary.description {
                    Text(description)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(alignment: .top) {
                Image(systemName: "sparkles")
                if let rationale = itinerary.rationale {
                    Text(rationale)
                        .contentTransition(.opacity)
                        .rationaleStyle()
                }
            }
            
            if let days = itinerary.days {
                ForEach(days, id: \.title) { plan in
                    DayView(
                        destination: tripPlanViewModel.tripContext!.destination,
                        plan: plan
                    )
                }
            }
        }
        .animation(.easeOut, value: itinerary)
        .itineraryStyle()
    }
}

private struct DayView: View {
    let destination: Destination
    let plan: DayPlan.PartiallyGenerated
    
    @State private var mapItem: MKMapItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottom) {
                PlanDetailMapView(
                    destination: destination,
                    landmarkMapItem: mapItem
                )
                .task(id: plan.destination) {
                    guard let planDestination = plan.destination, !planDestination.isEmpty else { return }
                    
                    if let fetchedItem = await LocationLookup().mapItem(atLocation: planDestination) {
                        self.mapItem = fetchedItem
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    if let title = plan.title {
                        Text(title)
                            .contentTransition(.opacity)
                            .font(.headline)
                    }
                    if let subtitle = plan.subtitle {
                        Text(subtitle)
                            .contentTransition(.opacity)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .blurredBackground()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding([.horizontal, .top], 4)
            
            ActivityList(activities: plan.activities ?? [])
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.bottom)
        .geometryGroup()
        .card()
        .animation(.easeInOut, value: plan)
    }
    
    
}

private struct ActivityList: View {
    let activities: [Activity].PartiallyGenerated
    
    var body: some View {
        ForEach(activities) { activity in
            HStack(alignment: .top, spacing: 12) {
                if let title = activity.title {
                    ActivityIcon(symbolName: activity.type?.symbolName)
                    VStack(alignment: .leading) {
                        Text(title)
                            .contentTransition(.opacity)
                            .font(.headline)
                        if let description = activity.description {
                            Text(description)
                                .contentTransition(.opacity)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
