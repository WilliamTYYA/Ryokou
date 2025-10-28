import FoundationModels
import SwiftUI

struct DestinationDetailView: View {
    let landmark: Landmark
    
    private let model = SystemLanguageModel.default

    var body: some View {
        // MARK: - [CODE-ALONG] Chapter 1.4.3: Replace availability with model.availability
        switch model.availability {
        case .available:
            TripPlanGeneratorView(landmark: landmark)
            
        case .unavailable:
            MessageView(
                landmark: self.landmark,
                message: """
                         Trip Planner is unavailable because \
                         Apple Intelligence has not been turned on.
                         """
            )
        @unknown default:
            MessageView(
                landmark: self.landmark,
                message: """
                         Trip Planner is unavailable. Try again later.
                         """
            )
        }
    }
}
