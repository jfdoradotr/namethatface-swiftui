//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftUI

struct AddView: View {
  @Environment(\.dismiss) var dismiss
  @State private var name: String = ""

  private let locationFetcher = LocationFetcher()

  let imageData: Data
  let onSave: (String, (Double?, Double?)) -> Void

  private var uiImage: UIImage {
    UIImage(data: imageData)!
  }

  private var isPhotoValid: Bool {
    UIImage(data: imageData) != nil
  }

  private var isValidName: Bool {
    name.trimmingCharacters(in: .whitespacesAndNewlines).count > 1
  }

  var body: some View {
    NavigationStack {
      Group {
        if let image = UIImage(data: imageData) {
          VStack {
            TextField("Name", text: $name)
              .textFieldStyle(.roundedBorder)
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
          }
        } else {
          ContentUnavailableView("Image not available", systemImage: "photo.badge.exclamationmark", description: Text("Image was not possible to load"))
        }
      }
      .padding()
      .onAppear {
        locationFetcher.start()
      }
      .navigationTitle("Add name")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          if isPhotoValid {
            Button("Save") {
              let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
              let locationCoordinates = locationFetcher.lastKnownLocation
              let latitude = locationCoordinates?.latitude
              let longitude = locationCoordinates?.longitude
              onSave(name, (latitude, longitude))
              dismiss()
            }
            .disabled(!isValidName)
          }
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  AddView(imageData: Data()) { _, _ in }
}
