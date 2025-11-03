//
//  RyokouApp.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI
import SwiftData

@main
struct RyokouApp: App {
    let modelContainer = DataModel.shared.modelContainer
    
    var body: some Scene {
        WindowGroup {
            RyokouMainView()
                .modelContainer(modelContainer)
        }
    }
}
