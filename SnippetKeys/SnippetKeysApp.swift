//
//  SnippetKeysApp.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/25/25.
//

import SwiftUI
import SwiftData

@main
struct SnippetKeysApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
              AppGroupBootstrap.bootstrapDefaults()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
/*
enum AppGroupBootstrap {
  static let groupID = "group.com.bludgeonsoft.snippetkeys" // match your App Group
  
  static func bootstrapDefaults() {
    guard let groupURL = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: groupID) else { return }
    let dest = groupURL.appendingPathComponent("Snippets.json")
    guard !FileManager.default.fileExists(atPath: dest.path) else { return }
    if let src = Bundle.main.url(forResource: "Snippets", withExtension: "json") {
      try? FileManager.default.copyItem(at: src, to: dest)
    }
  }
}
*/
