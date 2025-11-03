import FoundationModels
import SwiftUI
import MapKit
import SwiftData

struct ItineraryView: View {
    private let itinerary: Itinerary.PartiallyGenerated
    
    init(itinerary: Itinerary.PartiallyGenerated) {
        self.itinerary = itinerary
    }
    
    @Environment(TripPlanViewModel.self) private var tripPlanViewModel
    @Environment(NavigationModel.self) private var navigationModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var isSaving = false
        
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
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await upsertTripPlanAndPopWithUI() }
                }
                .disabled(!canSave || isSaving)
            }
        }
    }
}

extension ItineraryView {
    // Turn PartiallyGenerated into a fully concrete Itinerary, or fail if anything is missing.
    private func concreteItinerary(from p: Itinerary.PartiallyGenerated) -> Itinerary? {
        guard
            let title = p.title,
            let destinationName = p.destinationName,
            let description = p.description,
            let rationale = p.rationale,
            let dayParts = p.days, dayParts.count == tripPlanViewModel.tripContext!.dayCount
        else { return nil }
        
        var days: [DayPlan] = []
        days.reserveCapacity(dayParts.count)
        
        for d in dayParts {
            guard
                let dayTitle = d.title,
                let subtitle  = d.subtitle,
                let dest      = d.destination,
                let acts      = d.activities, acts.count == 4
            else { return nil }
            
            var activities: [Activity] = []
            activities.reserveCapacity(acts.count)
            
            for a in acts {
                guard
                    let type = a.type,
                    let atitle = a.title,
                    let adesc  = a.description
                else { return nil }
                activities.append(Activity(type: type, title: atitle, description: adesc))
            }
            
            days.append(DayPlan(title: dayTitle, subtitle: subtitle, destination: dest, activities: activities))
        }
        
        return Itinerary(title: title,
                         destinationName: destinationName,
                         description: description,
                         rationale: rationale,
                         days: days)
    }
    
    private var concreteItineraryReady: Itinerary? {
        concreteItinerary(from: itinerary)
    }
    
    private var canSave: Bool {
        concreteItineraryReady != nil &&
        tripPlanViewModel.selectedFlight != nil &&
        tripPlanViewModel.selectedHotel  != nil
    }
    
    @MainActor
    private func upsertTripPlanAndPop() {
        guard let ctx = tripPlanViewModel.tripContext,
              let solidItinerary = concreteItineraryReady else { return }
        
        // Parse dates from your ISO strings (same as before)...
        guard let depDate = DateFormatter.parseISO(ctx.departureDateISO),
              let retDate = DateFormatter.parseISO(ctx.returnDateISO) else { return }
        
        // Capture plain values for the predicate
        let destID  = ctx.destination.id
        // ✅ Build predicate comparing model fields to captured values
        let predicate = #Predicate<TripPlan> { plan in
            plan.destinationID == destID &&
            plan.departureDate == depDate &&
            plan.returnDate == retDate
        }
        
        // If your SwiftData context name clashes, qualify it:
        // @Environment(\.modelContext) private var modelContext: SwiftData.ModelContext
        var fetch = FetchDescriptor(predicate: predicate)
        fetch.fetchLimit = 1
//        let fetch = FetchDescriptor<TripPlan>(predicate: predicate, fetchLimit: 1)
        let existing = try? modelContext.fetch(fetch).first
        
        let row: TripPlan = existing ?? {
            let r = TripPlan(
                origin: ctx.origin,
                destinationID: ctx.destination.id,
                destinationName: ctx.destination.name,
                departureDate: depDate,
                returnDate: retDate,
                flightBudgetUSD: ctx.flightBudgetUSD,
                hotelBudgetUSD: ctx.hotelBudgetUSD
            )
            modelContext.insert(r)
            return r
        }()
        
        row.isFavorite     = true
        row.selectedFlight = tripPlanViewModel.selectedFlight!  // non-nil by canFavorite
        row.selectedHotel  = tripPlanViewModel.selectedHotel!   // non-nil by canFavorite
        row.itinerary      = solidItinerary                     // fully concrete (no optionals inside)
        
        try? modelContext.save()
        
        // Pop the Trip tab to root (as you already do elsewhere)
        withAnimation { NavigationModel.shared.tripPlanPath.removeAll() }
    }
    
    func upsertTripPlanAndPopWithUI() async {
        guard !isSaving else { return }
        isSaving = true
        
        upsertTripPlanAndPop()
        isSaving = false
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
