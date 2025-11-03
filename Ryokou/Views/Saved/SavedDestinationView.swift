//
//  SavedDestinationView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 11/3/25.
//

import SwiftUI

struct SavedDestinationView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            SavedDestinationListView()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "Search Cities")
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
    }
}

#Preview {
    SavedDestinationView()
}
