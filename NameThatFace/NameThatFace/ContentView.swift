//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import PhotosUI
import SwiftUI

struct Face: Identifiable {
  let id = UUID()
  let data: Data
  var name: String

  var uiImage: UIImage { UIImage(data: data)! }
}

struct ContentView: View {
  @State private var pickerItem: PhotosPickerItem?
  @State private var newFaceAdded: Face?
  @State private var faces = [Face]()

  private let columns = [GridItem(.adaptive(minimum: 150))]

  var body: some View {
    NavigationStack {
      VStack {
        if faces.isEmpty {
          ContentUnavailableView(
            "No Picture",
            systemImage: "photo.badge.plus",
            description: Text("Tap to import a photo")
          )
        } else {
          ScrollView {
            LazyVGrid(columns: columns) {
              ForEach(faces) { face in
                VStack {
                  Image(uiImage: face.uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.vertical)
                  VStack {
                    Text(face.name)
                      .font(.headline)
                      .foregroundStyle(.white)
                  }
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(Color.secondary.opacity(0.75))
                }
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.secondary)
                )
              }
            }
            .padding(.horizontal)
          }
          .scrollBounceBehavior(.basedOnSize)
        }
      }
      .navigationTitle("Name That Face")
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
        AddView(imageData: face.data) { name in
          let newFace = Face(data: face.data, name: name)
          faces.append(newFace)
          newFaceAdded = nil
        }
        .interactiveDismissDisabled()
      }
    }
  }
}

#Preview {
  ContentView()
}
