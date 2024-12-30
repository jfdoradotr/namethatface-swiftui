//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import SwiftUI

struct ContentView: View {
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
          Button("Add photo", systemImage: "plus") {
            
          }
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
