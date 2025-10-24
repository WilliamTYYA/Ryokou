//
//  MainTabView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

/// The main tab view shown after the user has created their profile. It contains
/// tabs for searching new trips, viewing saved trips and editing the profile.
struct MainTabView: View {
    var body: some View {
        TabView {
            LandmarksHomeView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            Text("Saved Trips")
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
