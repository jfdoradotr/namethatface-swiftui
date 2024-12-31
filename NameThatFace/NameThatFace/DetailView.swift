//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftUI

struct DetailView: View {
  @Environment(\.dismiss) var dismiss

  let face: Face
  let onDelete: (Face) -> Void

  var body: some View {
    Image(uiImage: face.uiImage)
      .resizable()
      .scaledToFit()
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
