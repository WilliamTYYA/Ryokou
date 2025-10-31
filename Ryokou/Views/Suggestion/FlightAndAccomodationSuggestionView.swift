import SwiftUI

struct FlightAndAccomodationSuggestionView: View {
    private let suggestion: FlightAndAccommodationSuggestion.PartiallyGenerated
    private var viewModel: FlightAndAccommodationSuggestionViewModel
    
    init(viewModel flightAndAccomodationSuggestionViewModel: FlightAndAccommodationSuggestionViewModel, suggestion flightAndAccomodationSuggestion: FlightAndAccommodationSuggestion.PartiallyGenerated) {
        self.suggestion = flightAndAccomodationSuggestion
        self.viewModel = flightAndAccomodationSuggestionViewModel
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            
            if let flights = suggestion.flights {
                OptionSectionHeader(
                    systemImage: "airplane.circle.fill",
                    title: "Flights"
                )
                
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(flights.enumerated()), id: \.offset) { idx, f in
                        if let airline = f.airline,
                           let flightNumber = f.flightNumber,
                           let departureTime = f.departureTime,
                           let arrivalTime = f.arrivalTime,
                           let price = f.price {
                            
                            let isSelected = viewModel.selectedFlight?.flightNumber == flightNumber
                            
                            SelectRow(isSelected: isSelected) {
                                viewModel.selectedFlight = FlightResult(
                                    airline: airline,
                                    flightNumber: flightNumber,
                                    price: price,
                                    departureTime: departureTime,
                                    arrivalTime: arrivalTime
                                )
                            } content: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(airline) \(flightNumber)")
                                            .contentTransition(.opacity)
                                            .font(.headline)
                                        
                                        Text("\(departureTime) → \(arrivalTime)")
                                            .contentTransition(.opacity)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(String(format: "$%.0f", price))
                                        .contentTransition(.opacity)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            
            if let hotels = suggestion.hotels {
                OptionSectionHeader(
                    systemImage: "bed.double.circle.fill",
                    title: "Hotels"
                )
                
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(hotels.enumerated()), id: \.offset) { idx, h in
                        if let name = h.name,
                           let min = h.minimumPrice,
                           let max = h.maximumPrice {
                            
                            let isSelected = viewModel.selectedHotel?.name == name
                            
                            SelectRow(isSelected: isSelected) {
                                viewModel.selectedHotel = HotelResult(
                                    name: name,
                                    minimumPrice: min,
                                    maximumPrice: max,
                                    latitude: h.latitude,
                                    longitude: h.longitude
                                )
                            } content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(name)
                                            .contentTransition(.opacity)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text(String(format: "$%.0f–$%.0f", min, max))
                                            .contentTransition(.opacity)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .layoutPriority(1)
                                    }
                                    .lineLimit(1)
                                    
                                    if let r = h.regionCoordinate, let l = h.locationCoordinate {
                                        MapView(annotation: name, regionCoordinate: r, locationCoordinate: l)
                                            .frame(height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeOut, value: suggestion)
        .itineraryStyle()
        .navigationTitle("Choose Options")
    }
}

// MARK: - Section header

private struct OptionSectionHeader: View {
    let systemImage: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.yellow)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.yellow.opacity(0.2)))
            
            Text(title)
                .font(.title3).bold()
        }
        .padding(.horizontal, 4)
    }
}

private struct SelectRow<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder var content: Content
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.yellow.opacity(0.35))
                                .blendMode(.plusLighter)
                        }
                    }
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .geometryGroup()
    }
}
