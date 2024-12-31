//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import PhotosUI
import SwiftData
import SwiftUI

@Model
class Face: Hashable, Decodable {
  var id: UUID
  @Attribute(.externalStorage) var data: Data
  var name: String

  var uiImage: UIImage { UIImage(data: data)! }

  init(id: UUID, data: Data, name: String) {
    self.id = id
    self.data = data
    self.name = name
  }

  enum CodingKeys: CodingKey {
    case id, data, name
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.data = try container.decode(Data.self, forKey: .data)
    self.name = try container.decode(String.self, forKey: .name)
  }
}

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var pickerItem: PhotosPickerItem?
  @State private var newFaceAdded: Face?
  @Query(sort: \Face.name) private var faces: [Face]

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
              ForEach(faces, id: \.id) { face in
                NavigationLink(value: face) {
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
            newFaceAdded = Face(
              id: UUID(),
              data: data,
              name: ""
            )
          }
        }
      }
      .sheet(item: $newFaceAdded) { face in
        AddView(imageData: face.data) { name in
          let newFace = Face(
            id: UUID(),
            data: face.data,
            name: name
          )
          modelContext.insert(newFace)
          newFaceAdded = nil
        }
        .interactiveDismissDisabled()
      }
      .navigationDestination(for: Face.self) { face in
        DetailView(face: face) {
          modelContext.delete($0)
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
