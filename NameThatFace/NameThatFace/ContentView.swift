//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
  @State private var pickerItem: PhotosPickerItem?
  @State private var selectedImage: Image?

  var body: some View {
    NavigationStack {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
      }
      .toolbar {
        ToolbarItem {
          PhotosPicker(selection: $pickerItem, matching: .images) {
            Label("Select an image", systemImage: "photo.badge.plus")
          }
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
