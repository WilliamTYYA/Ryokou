//
//  MainTabView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

/// The main tab view shown after the user has created their profile. It contains
/// tabs for searching new trips, viewing saved trips and editing the profile.
struct RyokouTabView: View {
//    let username: String
//    let onSignOut: () -> Void
    
    var body: some View {
        TabView {
            DestinationListView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            Text("Saved Trips")
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                
            ProfileView()
//                ProfileView(username: username, onSignOut: onSignOut)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
