/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for displaying a message when generating an itinerary for a landmark fails.
*/

import SwiftUI

struct MessageView: View {
    let error: Error?
    let destination: Destination
    let message: String?
    
    init(error: Error? = nil, destination: Destination, message: String? = nil) {
        self.error = error
        self.destination = destination
        self.message = message
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let error {
                Text("\(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .padding(5)
            } else if let message {
                Text("\(message)")
                    .foregroundStyle(.black)
                    .font(.title3)
                    .padding(15)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .top) {
            ItineraryHeader(destination: destination)
            .opacity(0.6)
        }
    }
}
