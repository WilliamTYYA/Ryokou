/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that renders a Landmark location on a map.
*/

import SwiftUI
import MapKit

struct MapView: View {
    let coordinateRegion: MKCoordinateRegion
    var coordinate: CLLocationCoordinate2D

    var body: some View {
        Map(initialPosition: .region(coordinateRegion), interactionModes: []) {
            Annotation("Coordinate", coordinate: landmarkMapItem.location.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(.indigo)
            }
        }
        .disabled(true)
    }
}
