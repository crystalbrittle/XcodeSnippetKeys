//
//  AppGroupBootstrap.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/26/25.
//


import Foundation

enum AppGroupBootstrap {
    /// 🔴 Replace with your actual App Group ID.
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

    /// Computed convenience to show the full path in the UI.
    static var snippetsFilePath: String? {
        guard let url = containerURL()?.appendingPathComponent("Snippets.json") else { return nil }
        return url.path
    }

    /// Ensures the live Snippets.json exists in the App Group.
    /// - Returns: .success(url) if ready, otherwise .failure(error).
    @discardableResult
    static func ensureSnippetsFile() -> Result<URL, Error> {
        guard let container = containerURL() else {
            return .failure(makeError("App Group not available. Did you add App Groups capability to both targets and use the SAME group ID? (\(groupID))"))
        }
        let dest = container.appendingPathComponent("Snippets.json")

        // If it already exists, we're done.
        if FileManager.default.fileExists(atPath: dest.path) {
            return .success(dest)
        }

        // Try to copy a bundled default from the host app’s resources
        if let src = Bundle.main.url(forResource: "Snippets", withExtension: "json") {
            do {
                try FileManager.default.copyItem(at: src, to: dest)
                return .success(dest)
            } catch {
                // Fall through to write a minimal default
            }
        }

        // Write a minimal default if no bundled file was found or copy failed
        let defaultJSON = """
        {
          "selectionToken": "<#Section#>",
          "snippets": [
            { "id": "mark",   "title": "MARK",   "template": "// MARK: - <#Section#>",      "placement": "line"   },
            { "id": "trace",  "title": "trace()", "template": "trace(\\"\\\\(<#Section#>)\\")", "placement": "inline" },
            { "id": "parens", "title": "parens", "template": "\\\\(<#Section#>)",            "placement": "inline" }
          ]
        }
        """
        do {
            try defaultJSON.data(using: .utf8)?.write(to: dest, options: .atomic)
            return .success(dest)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Helpers

    private static func containerURL() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)
    }

    private static func makeError(_ message: String) -> NSError {
        NSError(domain: "SnippetKeys", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
