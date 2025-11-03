import FoundationModels
import SwiftUI
import MapKit
import SwiftData

struct SavedItineraryView: View {
    private let tripPlan: TripPlan
    
    init(tripPlan: TripPlan) {
        self.tripPlan = tripPlan
    }
    
    @Environment(\.modelContext) private var modelContext
    @State private var isSaving = false
    
    private var destination: Destination {
        ModelData.destinations.first(where: { $0.name == tripPlan.destinationName })!
    }
        
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    if let title = tripPlan.itinerary?.title {
                        Text(title)
                            .contentTransition(.opacity)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    if let description = tripPlan.itinerary?.description {
                        Text(description)
                            .contentTransition(.opacity)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                    if let rationale = tripPlan.itinerary?.rationale {
                        Text(rationale)
                            .contentTransition(.opacity)
                            .rationaleStyle()
                    }
                }
                
                if let days = tripPlan.itinerary?.days {
                    ForEach(days, id: \.title) { plan in
                        SavedDayView(
                            destination: destination,
                            plan: plan
                        )
                    }
                }
            }
            .itineraryStyle()
            .padding()
            .navigationTitle("Itinerary")
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
//                        Task { await upsertTripPlanAndPopWithUI() }
                    }
//                    .disabled(!canSave || isSaving)
                }
            }
        }
        .headerStyle(destination: destination)
    }
}

private struct SavedDayView: View {
    let destination: Destination
    let plan: DayPlan
    
    @State private var mapItem: MKMapItem?
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottom) {
                PlanDetailMapView(
                    destination: destination,
                    landmarkMapItem: mapItem
                )
                .task(id: plan.destination) {
                    if let fetchedItem = await LocationLookup().mapItem(atLocation: plan.destination) {
                        self.mapItem = fetchedItem
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(plan.title)
                        .contentTransition(.opacity)
                        .font(.headline)
                    Text(plan.subtitle)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .blurredBackground()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding([.horizontal, .top], 4)
            
            SavedActivityList(activities: plan.activities)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.bottom)
        .geometryGroup()
        .card()
        .animation(.easeInOut, value: plan)
    }
    
    
}

private struct SavedActivityList: View {
    let activities: [Activity]
    
    var body: some View {
        ForEach(Array(activities.enumerated()), id: \.offset) { idx, activity in
            HStack(alignment: .top, spacing: 12) {
                ActivityIcon(symbolName: activity.type.symbolName)
                
                VStack(alignment: .leading) {
                    Text(activity.title)
                        .contentTransition(.opacity)
                        .font(.headline)
                    Text(activity.description)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
