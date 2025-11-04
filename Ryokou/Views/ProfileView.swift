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
    
    @Environment(\.openURL) private var openURL
    
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
                
                Section {
                    Button(action: openLinkedIn) {
                        Text({ () -> AttributedString in
                            var s = AttributedString("Hi, I'm ")
                            var name = AttributedString("Thiha Ye Yint Aung")
                            name.foregroundColor = .blue
                            name.inlinePresentationIntent = .stronglyEmphasized
                            s.append(name)
                            s.append(AttributedString("\nTap to connect on LinkedIn"))
                            return s
                        }())
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint) // link-like color
                }
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

extension ProfileView {
    private func openLinkedIn() {
        let appURL = URL(string: "linkedin://in/thiha-ye-yint-aung")!
        let webURL = URL(string: "https://www.linkedin.com/in/thiha-ye-yint-aung")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:]) { success in
                if !success { openURL(webURL) }
            }
        } else {
            openURL(webURL)
        }
    }
}
