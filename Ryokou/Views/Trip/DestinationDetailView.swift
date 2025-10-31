import FoundationModels
import SwiftUI

struct DestinationDetailView: View {
    let destination: Destination
    @Environment(NavigationModel.self) private var navigationModel
    
    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            TripPlanGeneratorView(destination: destination) { ctx in
                navigationModel.tripPlanPath.append(.suggestions(ctx))
            }
            
        case .unavailable:
            MessageView(
                destination: self.destination,
                message: """
                         Trip Planner is unavailable because \
                         Apple Intelligence has not been turned on.
                         """
            )
        @unknown default:
            MessageView(
                destination: self.destination,
                message: """
                         Trip Planner is unavailable. Try again later.
                         """
            )
        }
    }
}
