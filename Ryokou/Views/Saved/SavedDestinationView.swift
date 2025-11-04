//
//  SavedDestinationView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 11/3/25.
//

import SwiftUI

struct SavedDestinationView: View {
    @Environment(NavigationModel.self) private var navigationModel
    @State private var searchText = ""
    
    var body: some View {
        @Bindable var navigationModel = navigationModel
        
        NavigationStack(path: $navigationModel.savedPath) {
            SavedDestinationListView(searchText: searchText)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "Search Cities")
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
    }
}
