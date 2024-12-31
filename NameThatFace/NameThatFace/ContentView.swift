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
  @Query(sort: \Face.name) private var faces: [Face]

  private let columns = [GridItem(.adaptive(minimum: 150))]

  @State private var authenticationState = AuthenticationState.locked

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
            ScrollView {
              LazyVGrid(columns: columns) {
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
    } else {
      AuthButton(action: authenticate)
        .alert("Authentication error", isPresented: $isShowingAuthenticationError) {
          Button("OK") { }
        } message: {
          Text(authenticationError)
        }
    }
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

// MARK: - NoPictureStateView

private extension ContentView {
  struct NoPictureStateView: View {
    var body: some View {
      ContentUnavailableView(
        "No Picture",
        systemImage: "photo.badge.plus",
        description: Text("Tap to import a photo")
      )
    }
  }
}

// MARK: - AuthButton

private extension ContentView {
  struct AuthButton: View {
    let action: () -> Void

    var body: some View {
      Button("Unlock", action: action)
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(.capsule)
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
          .frame(width: 100, height: 100)
          .padding(.vertical)
        VStack {
          Text(name)
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

#Preview {
  ContentView()
}
