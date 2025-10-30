import SwiftUI

struct ProfileView: View {
//    let username: String
//    let onSignOut: () -> Void
    
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
                    FloatingLabelTextField(
                        "Name",
                        text: $nameInput,
                        isEnabled: isEditing
                    )
                    FloatingLabelTextField(
                        "City",
                        text: $cityInput,
                        isEnabled: isEditing
                    )
                    FloatingLabelTextField(
                        "Country",
                        text: $countryInput,
                        isEnabled: isEditing
                    )
                } header: {
                    HStack {
                        Text("Profile")
                        Spacer()
                        ReadOnlyChip().allowsHitTesting(false)
                            .opacity(!isEditing ? 1 : 0)
                    }
                }
//                .disabled(!isEditing)
//                .opacity(isEditing ? 1 : 0.75)
                
                Section {
                    FloatingLabelTextField(
                        "Flight",
                        text: $flightBudgetInput,
                        keyboard: .decimalPad,
                        isEnabled: isEditing
                    )
                    FloatingLabelTextField(
                        "Hotel",
                        text: $hotelBudgetInput,
                        keyboard: .decimalPad,
                        isEnabled: isEditing
                    )
                    FloatingLabelTextField(
                        "Activities",
                        text: $activitiesBudgetInput,
                        keyboard: .decimalPad,
                        isEnabled: isEditing
                    )
                } header: {
                    HStack {
                        Text("Budgets (USD)")
                        Spacer()
                        ReadOnlyChip().allowsHitTesting(false)
                            .opacity(!isEditing ? 1 : 0)
                    }
                }
//                .disabled(!isEditing)
//                .opacity(isEditing ? 1 : 0.75)
                
//                VStack(spacing: 16) {
//                    Text("Hello, \(username)").font(.title2)
//                    Button("Sign out", action: onSignOut)
//                        .buttonStyle(.bordered)
//                }
            }
            .navigationTitle("Setup Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isEditing {
                        Button("Cancel") { cancelEdits() }
                    }
                }
                
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
//            .alert(isPresented: $showError) {
//                Alert(
//                    title: Text("Invalid Input"),
//                    message: Text("Please ensure all budget fields contain valid numbers."),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
            .alert("Invalid Input",
                   isPresented: $showError,
                   actions: { Button("OK", role: .cancel) { reloadFromProfile() } },
                   message: { Text("Please ensure all budget fields contain valid numbers.") }
            )
            .onAppear {
                reloadFromProfile()
            }
            .onDisappear { cancelEdits() }
        }
    }
    
    private func reloadFromProfile() {
        nameInput = profile.username
        cityInput = profile.location.city
        countryInput = profile.location.country
        if let v = profile.budgetAmount(for: "Flight") {
            flightBudgetInput = String(format: "%.2f", v)
        }
        if let v = profile.budgetAmount(for: "Hotel") {
            hotelBudgetInput = String(format: "%.2f", v)
        }
        if let v = profile.budgetAmount(for: "Activity") {
            activitiesBudgetInput = String(format: "%.2f", v)
        }
    }
    
    private func cancelEdits() {
        isEditing = false
        // throw away unsaved text and restore from AppStorage
        reloadFromProfile()
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
