//
//  MainTabView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

struct RyokouTabView: View {
    
    var body: some View {
        TabView {
            DestinationListView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SavedDestinationView()
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
