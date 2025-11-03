//
//  ModelData.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 11/3/25.
//

import Foundation
import SwiftData

actor DataModel {
    static let shared = DataModel()
    
    private static let container: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: TripPlan.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        return modelContainer
    }()
    
    nonisolated var modelContainer: ModelContainer {
        Self.container
    }
}
