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
  @State private var isUnlocked = false
  @State private var authenticationError = "Unknown error"
  @State private var isShowingAuthenticationError = false
  @Query(sort: \Face.name) private var faces: [Face]

  private let columns = [GridItem(.adaptive(minimum: 150))]

  var body: some View {
    if isUnlocked {
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
    } else {
      Button("Unlock", action: authenticate)
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(.capsule)
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
              self.isUnlocked = true
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

#Preview {
  ContentView()
}
