//
//  ContentView.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/25/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
  @State private var errorMessage: String?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("SnippetKeys")
        .font(.title)
        .bold()
      
      Text("Manage your editable Snippets.json used by the Xcode Source Editor Extension.")
      
      HStack(spacing: 12) {
        Button("Open Snippets.json…") {
          switch AppGroupBootstrap.ensureSnippetsFile() {
            case .success(let url):
              NSWorkspace.shared.open(url) // opens in default editor
            case .failure(let err):
              errorMessage = err.localizedDescription
          }
        }
        
        Button("Reveal in Finder") {
          switch AppGroupBootstrap.ensureSnippetsFile() {
            case .success(let url):
              NSWorkspace.shared.activateFileViewerSelecting([url])
            case .failure(let err):
              errorMessage = err.localizedDescription
          }
        }
      }
      
      Divider()
      
      VStack(alignment: .leading, spacing: 6) {
        Text("App Group").bold()
        Text(AppGroupBootstrap.groupID)
          .font(.system(.body, design: .monospaced))
        if let path = AppGroupBootstrap.snippetsFilePath {
          Text("Path:")
          Text(path)
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(.secondary)
            .lineLimit(3)
            .textSelection(.enabled)
        }
      }
      
      Spacer()
    }
    .padding()
    .alert("Error", isPresented: Binding(get: { errorMessage != nil },
                                         set: { if !$0 { errorMessage = nil } })) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(errorMessage ?? "")
    }
  }
}
