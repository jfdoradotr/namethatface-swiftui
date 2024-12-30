//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import PhotosUI
import SwiftUI

struct Face: Identifiable {
  let id = UUID()
  let data: Data
  var name: String
}

struct ContentView: View {
  @State private var pickerItem: PhotosPickerItem?
  @State private var newFaceAdded: Face?

  var body: some View {
    NavigationStack {
      VStack {
        ContentUnavailableView(
          "No Picture",
          systemImage: "photo.badge.plus",
          description: Text("Tap to import a photo")
        )
      }
      .toolbar {
        ToolbarItem {
          PhotosPicker(
            selection: $pickerItem,
            matching: .any(of: [.images, .not(.screenshots)])
          ) {
            Label("Select an image", systemImage: "photo.badge.plus")
          }
        }
      }
      .onChange(of: pickerItem) {
        Task {
          if let data = try await pickerItem?.loadTransferable(type: Data.self) {
            newFaceAdded = Face(data: data, name: "")
          }
        }
      }
      .sheet(item: $newFaceAdded) { face in
        AddView(imageData: face.data) { _ in }
          .interactiveDismissDisabled()
      }
    }
  }
}

#Preview {
  ContentView()
}
