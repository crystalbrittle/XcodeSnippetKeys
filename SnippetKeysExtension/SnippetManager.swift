//
//  SnippetManager.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/25/25.
//

import Foundation

final class SnippetManager {
  static let shared = SnippetManager()
  private init() {}
  
  // Set this to your real group id
  private let appGroupID = "group.com.bludgeonsoft.snippetkeys"
  
  private(set) var config = SnippetConfig(selectionToken: "<#Section#>", snippets: [])
  
  func reload() {
    // 1) Try App Group (user-editable)
    if let groupURL = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
      .appendingPathComponent("Snippets.json"),
       let data = try? Data(contentsOf: groupURL),
       let parsed = try? JSONDecoder().decode(SnippetConfig.self, from: data) {
      self.config = parsed
      return
    }
    
    // 2) Fallback: bundled default (read-only)
    if let url = Bundle.main.url(forResource: "Snippets", withExtension: "json"),
       let data = try? Data(contentsOf: url),
       let parsed = try? JSONDecoder().decode(SnippetConfig.self, from: data) {
      self.config = parsed
      return
    }
    
    // 3) Empty fallback
    self.config = SnippetConfig(selectionToken: "<#Section#>", snippets: [])
  }
  
  func snippet(forCommandIdentifier identifier: String) -> Snippet? {
    guard let id = identifier.split(separator: ".").last.map(String.init) else { return nil }
    return config.snippets.first(where: { $0.id == id })
  }
}
