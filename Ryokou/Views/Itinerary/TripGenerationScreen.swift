//
//  TripGenerationScreen.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 11/1/25.
//

import SwiftUI

struct TripGenerationScreen<Content: View>: View {
    enum Mode {
        case suggestions((FlightAndHotelSuggestion.PartiallyGenerated) -> Content)
        case itinerary((Itinerary.PartiallyGenerated) -> Content)
    }
    
    @Environment(TripPlanViewModel.self) private var tripPlanViewModel
    
    let mode: Mode
    
    var body: some View {
        let generator = tripPlanViewModel.tripSuggestionItineraryGenerator
        let context = tripPlanViewModel.tripContext
        
        ScrollView {
            switch mode {
            case .suggestions(let render):
                if let suggestion = generator?.suggestion {
                    render(suggestion)
                        .padding()
                } else {
                    ProgressView("Finding Options…")
                        .padding(.top, 120)
                        .padding(.top)
                }
                
            case .itinerary(let render):
                if let itinerary = generator?.itinerary {
                    render(itinerary)
                        .padding()
                } else {
                    ProgressView("Building Itinerary…")
                        .padding(.top, 120)
                        .padding(.top)
                }
            }
        }
        .headerStyle(destination: context!.destination)
        .task {
            await runGenerationIfNeeded(generator: generator!, context: context!, mode: mode)
        }
    }
    
    private func runGenerationIfNeeded(generator: TripSuggestionItineraryGenerator,
                                       context: InputContextForItineraryGenerator,
                                       mode: Mode) async {
        switch mode {
        case .suggestions:
            if generator.suggestion == nil || generator.tripContext != context {
                await generator.generateFlightAndHotelSuggestion(context: context)
            }
        case .itinerary:
            if generator.itinerary == nil || generator.tripContext != context {
                await generator.generateItinerary(context: context)
            }
        }
    }
}
