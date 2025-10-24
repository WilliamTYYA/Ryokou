import SwiftUI

struct ProfileView: View {
    @State private var isEditing: Bool = false
    
    @AppStorage("profile") private var profile: Profile = .sample
    
    @State private var nameInput = ""
    @State private var cityInput = ""
    @State private var countryInput = ""
    @State private var flightBudgetInput = ""
    @State private var hotelBudgetInput = ""
    @State private var activitiesBudgetInput = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $nameInput)
                    TextField("City", text: $cityInput)
                    TextField("Country", text: $countryInput)
                } header: {
                    HStack {
                        Text("Profile")
                        Spacer()
                        if !isEditing {
                            ReadOnlyChip().allowsHitTesting(false)
                        }
                    }
                }
                .disabled(!isEditing)
                .opacity(isEditing ? 1 : 0.75)
                
                Section {
                    TextField("Flight Budget", text: $flightBudgetInput)
                        .keyboardType(.decimalPad)
                    TextField("Hotel Budget", text: $hotelBudgetInput)
                        .keyboardType(.decimalPad)
                    TextField("Activities Budget", text: $activitiesBudgetInput)
                        .keyboardType(.decimalPad)
                } header: {
                    HStack {
                        Text("Budgets (USD)")
                        Spacer()
                        if !isEditing {
                            ReadOnlyChip().allowsHitTesting(false)
                        }
                    }
                }
                .disabled(!isEditing)
                .opacity(isEditing ? 1 : 0.75)
            }
            .navigationTitle("Setup Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isEditing {
                            saveProfile()
                            isEditing = false
                        } else {
                            isEditing = true
                        }
                    } label: {
                        Text(isEditing ? "Save" : "Edit")
                            .contentTransition(.identity) // no cross-fade of the text
                    }
                    .animation(.none, value: isEditing)
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text("Please ensure all budget fields contain valid numbers."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                // Prepopulate fields from stored profile
                nameInput = profile.username
                cityInput = profile.location.city
                countryInput = profile.location.country
                if let flight = profile.budgetAmount(for: "Flight") {
                    flightBudgetInput = String(format: "%.2f", flight)
                }
                if let hotel = profile.budgetAmount(for: "Hotel") {
                    hotelBudgetInput = String(format: "%.2f", hotel)
                }
                if let activities = profile.budgetAmount(for: "Activity") {
                    activitiesBudgetInput = String(format: "%.2f", activities)
                }
            }
        }
    }
    
    private func saveProfile() {
        guard
            let flightValue = Double(flightBudgetInput.trimmingCharacters(in: .whitespaces)),
            let hotelValue = Double(hotelBudgetInput.trimmingCharacters(in: .whitespaces)),
            let activitiesValue = Double(activitiesBudgetInput.trimmingCharacters(in: .whitespaces))
        else {
            showError = true
            return
        }
        
        var updated = profile
        updated.username = nameInput
        updated.location = Address(city: cityInput, country: countryInput)
        updated.setBudget(name: "Flight", amount: flightValue)
        updated.setBudget(name: "Hotel", amount: hotelValue)
        updated.setBudget(name: "Activity", amount: activitiesValue)
        profile = updated
    }
}

private struct ReadOnlyChip: View {
    var body: some View {
        Label("Read-only", systemImage: "lock.fill")
            .font(.caption2)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
