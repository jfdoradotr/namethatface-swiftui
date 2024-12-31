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
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
          )
        )
      )
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        VStack {
          Image(uiImage: face.uiImage)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .gray.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)

        if let startPosition, let coordinates = face.coordinates {
          VStack {
            Map(initialPosition: startPosition) {
              Marker(coordinate: coordinates, label: {
                Label(face.name, systemImage: "mappin.circle.fill")
                  .foregroundColor(.blue)
                  .font(.caption)
              })
            }
            .disabled(true)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, lineWidth: 1)
            )
            .shadow(radius: 5)

            HStack {
              Text("Coordinates:")
                .font(.subheadline)
                .fontWeight(.bold)
              Spacer()
              Text("Lat: \(coordinates.latitude), Lon: \(coordinates.longitude)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            }
            .padding(.horizontal)
          }
          .padding(.vertical)
        } else {
          Text("No location data available.")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .padding()
    }
    .scrollBounceBehavior(.basedOnSize)
    .navigationTitle(face.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        Button(action: {
          onDelete(face)
          dismiss()
        }) {
          Label("Delete", systemImage: "trash")
        }
        .tint(.red)
      }
    }
  }
}
