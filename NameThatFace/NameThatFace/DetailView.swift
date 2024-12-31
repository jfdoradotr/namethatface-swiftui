//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import MapKit
import SwiftUI

struct DetailView: View {
  @Environment(\.dismiss) var dismiss

  let face: Face
  let onDelete: (Face) -> Void

  private var startPosition: MapCameraPosition? {
    guard let coordinates = face.coordinates else { return nil }
    return MapCameraPosition
      .region(
        MKCoordinateRegion(
          center: coordinates,
          span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
          )
        )
      )
  }

  var body: some View {
    VStack {
      Image(uiImage: face.uiImage)
        .resizable()
        .scaledToFit()
      if let startPosition, let coordinates = face.coordinates {
        Map(initialPosition: startPosition) {
          Marker(coordinate: coordinates, label: { Text(face.name) })
        }
        .disabled(true)
      }
    }
    .navigationTitle(face.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        Button("Delete", systemImage: "trash") {
          onDelete(face)
          dismiss()
        }
      }
    }
  }
}
