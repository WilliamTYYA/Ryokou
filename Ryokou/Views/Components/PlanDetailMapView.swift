import SwiftUI
import MapKit

struct PlanDetailMapView: View {
    let destination: Destination
    var landmarkMapItem: MKMapItem?

    var body: some View {
        Map(initialPosition: .region(destination.coordinateRegion), interactionModes: []) {
            if let landmarkMapItem = landmarkMapItem {
                Annotation("Destination", coordinate: landmarkMapItem.location.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.indigo)
                }
            }
        }
        .disabled(true)
    }
}
