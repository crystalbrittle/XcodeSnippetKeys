//
//  SourceEditorExtension.swift
//  SnippetKeysExtension
//
//  Created by Mark Stramaglia on 8/25/25.
//

import XcodeKit

final class SourceEditorExtension: NSObject, XCSourceEditorExtension {
  func extensionDidFinishLaunching() {
    SnippetManager.shared.reload()
  }
  
  var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
    SnippetManager.shared.reload()
    let cls = NSStringFromClass(InsertSnippetCommand.self)
    let bundleID = Bundle.main.bundleIdentifier ?? "com.example.SnippetKeysExtension"
    return SnippetManager.shared.config.snippets.map { snip in
      [
        .classNameKey: cls,
        .identifierKey: "\(bundleID).\(snip.id)",
        .nameKey: "SnippetKeys ▸ Insert: \(snip.title)"
      ]
    }
  }
}
