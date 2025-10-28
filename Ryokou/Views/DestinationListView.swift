//
//  LandmarksHome.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/23/25.
//

import SwiftUI

struct DestinationListView: View {
    @State private var searchText = ""
    
    private var filteredLandmarks: [Destination] {
        ModelData.destinations.filter { lm in
            searchText.isEmpty || lm.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Where would you like to go today!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                if filteredLandmarks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No matches")
                            .font(.headline)
                        Text("Try another city.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                } else {
                    LazyVStack(alignment: .center, spacing: 20) {
                        ForEach(filteredLandmarks) { landmark in
                            NavigationLink(destination: DestinationDetailView(landmark: landmark)) {
                                DestinationListCardView(landmark: landmark)
                                    .frame(height: 200)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, prompt: "Search Cities")
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
//        .searchSuggestions {
//            // quick suggestions
//            ForEach(ModelData.landmarks) { lm in
//                Text(lm.name).searchCompletion(lm.name)
//            }
//        }
    }
}

struct DestinationListCardView: View {
    let landmark: Destination
    
    var body: some View {
        
        Image(landmark.thumbnailImageName)
            .resizable()
            .overlay {
                ReadabilityRoundedRectangle()
            }
            .overlay(alignment: .bottomLeading) {
                Text(landmark.name)
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
            }
            .cornerRadius(15.0)
            .clipped()
    }
}

