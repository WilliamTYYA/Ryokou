//
//  ContentView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI
import SwiftData

struct RyokouMainView: View {
    @State private var navigationModel: NavigationModel = .shared
    
    var body: some View {
        RyokouTabView()
            .environment(navigationModel)
    }
}
