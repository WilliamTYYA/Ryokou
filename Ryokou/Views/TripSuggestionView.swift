import SwiftUI

struct TripSuggestionView: View {
    let suggestion: TripSuggestion.PartiallyGenerated
    private var vm: TripSuggestionViewModel
    
    init(vm: TripSuggestionViewModel, suggestion: TripSuggestion.PartiallyGenerated) {
        self.suggestion = suggestion
        self.vm = vm
    }
    
    var body: some View {
        NavigationStack {
            LazyVStack(alignment: .leading, spacing: 16) {
                if let flights = suggestion.flights {
                    ForEach(flights, id: \.flightNumber) { f in
                        if let airline = f.airline, let flightNumber = f.flightNumber, let departureTime = f.departureTime, let arrivalTime = f.arrivalTime, let price = f.price {
                            
                            SelectRow(isSelected: vm.selectedFlight?.flightNumber == f.flightNumber) {
                                vm.selectedFlight = FlightResult(
                                    airline: airline,
                                    flightNumber: flightNumber,
                                    price: price,
                                    departureTime: departureTime,
                                    arrivalTime: arrivalTime
                                )
                            } content: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(airline) \(flightNumber)")
                                            .font(.headline)
                                        Text("\(departureTime) → \(arrivalTime)")
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if let price = f.price {
                                        Text(String(format: "$%.0f", price))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .contentTransition(.opacity)
                                .rationaleStyle()
                            }
                        }
                        
                    }
                }
                
                if let hotels = suggestion.hotels {
                    ForEach(hotels) { h in
                        if let name = h.name, let minimumPrice = h.minimumPrice, let MaximumPrice = h.maximumPrice, let latitude = h.latitude, let longitude = h.longitude {
                            SelectRow(isSelected: vm.selectedHotel?.name == h.name) {
                                vm.selectedHotel = HotelResult(
                                    name: name,
                                    minimumPrice: minimumPrice,
                                    maximumPrice: MaximumPrice,
                                    latitude: latitude,
                                    longitude: longitude
                                )
                            } content: {
                                HStack {
                                    Text(name).font(.headline)
                                    Spacer()
                                    Text(String(format: "$%.0f+", minimumPrice)).foregroundStyle(.secondary)
                                }
                                .contentTransition(.opacity)
                                .rationaleStyle()
                            }
                        }
                    }
                }
            }
            .animation(.easeOut, value: suggestion)
            .itineraryStyle()
//            .padding(.top, 150)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Choose Options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        
                    }
                    .disabled(!vm.canConfirm)
                }
            }
        }
    }
}

private struct SelectRow<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder var content: Content
    
    var body: some View {
        Button(action: action) {
            HStack {
                content
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                }
            }
        }
    }
}
