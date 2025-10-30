/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that renders a Landmark location on a map.
*/

import SwiftUI
import MapKit

struct MapView: View {
    var annotation: String
    var regionCoordinate: MKCoordinateRegion
    var locationCoordinate: CLLocationCoordinate2D

    var body: some View {
        Map(initialPosition: .region(regionCoordinate), interactionModes: []) {
            Annotation(annotation, coordinate: locationCoordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .disabled(true)
    }
}
