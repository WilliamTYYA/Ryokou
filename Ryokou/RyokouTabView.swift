//
//  MainTabView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

//let username: String
//let onSignOut: () -> Void

//ProfileView(username: username, onSignOut: onSignOut)

struct RyokouTabView: View {
    
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
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
