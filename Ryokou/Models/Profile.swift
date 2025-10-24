//
//  Profile.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Foundation

struct Profile: Equatable, RawRepresentable, Codable {
    var username: String = ""
    var location: Address
    var budget: [Budget]
    
    init(username: String = "", location: Address, budget: [Budget]) {
        self.username = username
        self.location = location
        self.budget = budget
    }
    
    // --- RawRepresentable used by @AppStorage ---
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Profile.self, from: data)
        else { return nil }
        self = decoded
    }
    
    var rawValue: String {
        (try? String(data: JSONEncoder().encode(self), encoding: .utf8)) ?? ""
    }
    
    // --- Custom Codable to avoid rawValue recursion ---
    enum CodingKeys: String, CodingKey { case username, location, budget }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        username = try c.decode(String.self, forKey: .username)
        location = try c.decode(Address.self, forKey: .location)
        budget   = try c.decode([Budget].self, forKey: .budget)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(username, forKey: .username)
        try c.encode(location, forKey: .location)
        try c.encode(budget,   forKey: .budget)
    }
    
    /// Update or insert a budget item by name
    mutating func setBudget(name: String, amount: Double) {
        if let index = budget.firstIndex(where: { $0.name == name }) {
            budget[index].amount = amount
        } else {
            budget.append(Budget(name: name, amount: amount))
        }
    }
    
    /// Return the amount for a given budget name
    func budgetAmount(for name: String) -> Double? {
        budget.first(where: { $0.name == name })?.amount
    }
}

struct Address: Codable, Equatable {
    var city: String = ""
    var country: String = ""
}

struct Budget: Codable, Equatable {
    var name: String = ""
    var amount: Double = 0.0
}

extension Profile {
    static let sample = Profile(
        username: "William",
        location: Address(city: "Boston", country: "United States"),
        budget: [
            Budget(name: "Flight", amount: 1500.0),
            Budget(name: "Hotel", amount: 500.0),
            Budget(name: "Activity", amount: 3000.0)
        ]
    )
}

extension Profile {
    var flightBudgetUSD: Double { budgetAmount(for: "Flight") ?? 0 }
    var hotelBudgetUSD: Double { budgetAmount(for: "Hotel") ?? 0 }
}
