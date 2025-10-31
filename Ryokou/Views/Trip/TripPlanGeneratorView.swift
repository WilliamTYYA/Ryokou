//
//  TripPlanGeneratorView.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import SwiftUI

struct TripPlanGeneratorView: View {
    let destination: Destination
    let onGenerate: (TripContext) -> Void
    
    @AppStorage("profile") private var profile: Profile = .sample
    @State private var departure = Date()
    @State private var returning = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(destination.name)
                .padding(.top, 150)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(destination.description)
            
            DateRangeFields(departure: $departure,
                            returning: $returning,
                            minimumNights: 1)
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            GenerateButton(label: "Options") {
                let ctx = TripContext.from(profile: profile,
                                           destination: destination,
                                           departureDate: departure,
                                           returnDate: returning)
                
                onGenerate(ctx)
            }
        }
        .headerStyle(destination: destination)
    }
}
