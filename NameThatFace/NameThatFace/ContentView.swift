//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import PhotosUI
import LocalAuthentication
import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var pickerItem: PhotosPickerItem?
  @State private var newFaceAdded: Face?
  @State private var authenticationError = "Unknown error"
  @State private var isShowingAuthenticationError = false
  @State private var authenticationState = AuthenticationState.locked
  @Query(sort: \Face.name) private var faces: [Face]

  private enum AuthenticationState {
    case locked
    case unlocked
  }

  var body: some View {
    if authenticationState == .unlocked {
      NavigationStack {
        VStack {
          if faces.isEmpty {
            NoPictureStateView()
          } else {
            FaceListView(faces: faces)
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
              newFaceAdded = Face(id: UUID(), data: data, name: "", latitude: nil, longitude: nil)
            }
          }
        }
        .sheet(item: $newFaceAdded) { face in
          AddView(imageData: face.data) { name, coordinates in
            save(face: face, name: name, latitude: coordinates.0, longitude: coordinates.1)
          }
          .interactiveDismissDisabled()
        }
        .navigationDestination(for: Face.self) { face in
          DetailView(face: face, onDelete: delete)
        }
      }
    } else {
      AuthButton(action: authenticate)
        .alert("Authentication error", isPresented: $isShowingAuthenticationError) {
          Button("OK") { }
        } message: {
          Text(authenticationError)
        }
    }
  }
}

// MARK: -  Authentication

private extension ContentView {
  func save(face: Face, name: String, latitude: Double?, longitude: Double?) {
    let newFace = Face(
      id: UUID(),
      data: face.data,
      name: name,
      latitude: latitude,
      longitude: longitude
    )
    modelContext.insert(newFace)
    newFaceAdded = nil
  }

  func delete(face: Face) {
    modelContext.delete(face)
  }

  func authenticate() {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = "Please authenticate yourself to unlock."
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
        if success {
          self.authenticationState = .unlocked
        } else {
          self.authenticationError = "There was an error authenticating you; please try again."
          self.isShowingAuthenticationError = true
        }
      }
    } else {
      authenticationError = "Sorry, your device does not support biometric authentication"
      isShowingAuthenticationError = true
    }
  }
}

// MARK: - FaceListView

private extension ContentView {
  struct FaceListView: View {
    private let columns = [GridItem(.adaptive(minimum: 150))]

    let faces: [Face]

    var body: some View {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(faces, id: \.id) { face in
            NavigationLink(value: face) {
              RowItem(uiImage: face.uiImage, name: face.name)
            }
          }
        }
        .padding(.horizontal)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
  }
}

// MARK: - NoPictureStateView

private extension ContentView {
  struct NoPictureStateView: View {
    var body: some View {
      VStack {
        Image(systemName: "photo.fill.on.rectangle.fill")
          .font(.system(size: 64))
          .foregroundStyle(.gray)
        Text("No Pictures Added")
          .font(.headline)
          .foregroundStyle(.secondary)
        Text("Tap the button above to add your first photo.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
}

// MARK: - AuthButton

private extension ContentView {
  struct AuthButton: View {
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack {
          Image(systemName: "lock.fill")
          Text("Unlock")
        }
        .font(.headline)
        .padding()
        .background(Color.blue.gradient)
        .foregroundStyle(.white)
        .clipShape(.capsule)
      }
    }
  }
}

// MARK: - RowItem

private extension ContentView {
  struct RowItem: View {
    let uiImage: UIImage
    let name: String

    var body: some View {
      VStack {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(width: 120, height: 120)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .shadow(radius: 3)
        Text(name)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(1)
      }
      .padding()
      .background(Color(.systemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(radius: 5)
    }
  }
}

// MARK: - Previews

#Preview {
  ContentView()
}
