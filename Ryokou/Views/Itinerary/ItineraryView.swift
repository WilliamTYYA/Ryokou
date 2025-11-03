import FoundationModels
import SwiftUI
import MapKit

struct ItineraryView: View {
    private let itinerary: Itinerary.PartiallyGenerated
    
    init(itinerary: Itinerary.PartiallyGenerated) {
        self.itinerary = itinerary
    }
    
    @Environment(TripPlanViewModel.self) private var tripPlanViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var isFavorite = false
    // Loaded/created TripPlan row for this context
    @State private var tripPlan: TripPlan?
    
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
        .navigationTitle("Itinerary")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFavorite.toggle()
//                    upsertFavorite(isFavorite)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(isFavorite ? .red : .secondary)
                }
            }
        }
    }
}

//extension ItineraryView {
//    // MARK: - Persistence
//    
//    private func loadOrCreateTripPlanIfNeeded() async {
//        guard let ctx = tripPlanViewModel.tripContext else { return }
//        
//        let key = TripPlan.makeKey(for: ctx)
//        // Fetch existing
//        var fetched: TripPlan?
//        do {
//            let descriptor = FetchDescriptor<TripPlan>(
//                predicate: #Predicate { $0.id == key },
//                sortBy: [SortDescriptor(\.createdAt)]
//            )
//            fetched = try modelContext.fetch(descriptor).first
//        } catch {
//            // ignore for now
//        }
//        
//        if let existing = fetched {
//            tripPlan = existing
//            isFavorite = existing.isFavorite
//            // Always refresh itinerary snapshot
//            existing.itinerary = ItineraryDTO(itinerary)
//            try? modelContext.save()
//        } else {
//            // Create new
//            let newRow = TripPlan(
//                key: key,
//                origin: ctx.origin,
//                destinationID: ctx.destination.id,
//                destinationName: ctx.destination.name,
//                departureDate: Self.df.date(from: ctx.departureDateISO) ?? Date(),
//                returnDate: Self.df.date(from: ctx.returnDateISO) ?? Date(),
//                flightBudgetUSD: ctx.flightBudgetUSD,
//                hotelBudgetUSD: ctx.hotelBudgetUSD
//            )
//            newRow.selectedFlight = ctx.selectedFlight
//            newRow.selectedHotel  = ctx.selectedHotel
//            newRow.itinerary      = ItineraryDTO(itinerary)
//            modelContext.insert(newRow)
//            try? modelContext.save()
//            tripPlan = newRow
//            isFavorite = newRow.isFavorite
//        }
//    }
//    
//    private func upsertFavorite(_ fav: Bool) {
//        guard let row = tripPlan else { return }
//        row.isFavorite = fav
//        // keep latest itinerary snapshot
//        row.itinerary = ItineraryDTO(itinerary)
//        try? modelContext.save()
//    }
//    
//    // A small local ISO parser for dates
//    private static let df: DateFormatter = {
//        let f = DateFormatter()
//        f.calendar = Calendar(identifier: .gregorian)
//        f.locale = .init(identifier: "en_US_POSIX")
//        f.timeZone = .init(secondsFromGMT: 0)
//        f.dateFormat = "yyyy-MM-dd"
//        return f
//    }()
//}

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
