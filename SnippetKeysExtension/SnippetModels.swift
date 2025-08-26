//
//  SnippetModels.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/25/25.
//

import Foundation

struct SnippetConfig: Codable {
  var selectionToken: String?
  var snippets: [Snippet]
}

struct Snippet: Codable {
  var id: String
  var title: String
  var template: String
  /// "inline" or "line" (default "inline" if omitted)
  var placement: String?
}
