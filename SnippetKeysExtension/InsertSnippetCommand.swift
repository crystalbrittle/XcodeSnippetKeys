//
//  InsertSnippetCommand.swift
//  SnippetKeys
//
//  Created by Mark Stramaglia on 8/25/25.
//

import XcodeKit

final class InsertSnippetCommand: NSObject, XCSourceEditorCommand {
  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void) {
    SnippetManager.shared.reload()
    guard let snippet = SnippetManager.shared.snippet(forCommandIdentifier: invocation.commandIdentifier) else {
      completionHandler(nil); return
    }
    
    let token = SnippetManager.shared.config.selectionToken ?? "<#Section#>"
    let buffer = invocation.buffer
    var lastCaret: XCSourceTextPosition?
    
    for case let selection as XCSourceTextRange in buffer.selections {
      let selText = selectedText(in: buffer, range: selection)
      let templ = snippet.template.replacingOccurrences(of: token,
                                                        with: selText.isEmpty ? token : selText)
      
      if (snippet.placement ?? "inline").lowercased() == "line" {
        let lineIdx = max(0, selection.start.line)
        buffer.lines.insert(templ + "\n", at: lineIdx)
        lastCaret = XCSourceTextPosition(line: lineIdx, column: (templ as NSString).length)
      } else {
        lastCaret = replaceSelection(in: buffer, range: selection, with: templ)
      }
    }
    
    if let caret = lastCaret {
      let r = XCSourceTextRange(start: caret, end: caret)
      buffer.selections.removeAllObjects()
      buffer.selections.add(r)
    }
    completionHandler(nil)
  }
  
  private func selectedText(in buffer: XCSourceTextBuffer, range: XCSourceTextRange) -> String {
    let s = range.start, e = range.end
    if s.line == e.line {
      let line = (buffer.lines[s.line] as? String) ?? ""
      let a = line.index(line.startIndex, offsetBy: min(s.column, line.count))
      let b = line.index(line.startIndex, offsetBy: min(e.column, line.count))
      return String(line[a..<b])
    } else {
      var parts: [String] = []
      for i in s.line...e.line {
        var line = (buffer.lines[i] as? String) ?? ""
        if i == s.line { line = String(line.dropFirst(s.column)) }
        if i == e.line { line = String(line.prefix(e.column)) }
        parts.append(line)
      }
      return parts.joined()
    }
  }
  
  private func replaceSelection(in buffer: XCSourceTextBuffer,
                                range: XCSourceTextRange,
                                with text: String) -> XCSourceTextPosition {
    let s = range.start, e = range.end
    if s.line == e.line {
      let line = (buffer.lines[s.line] as? String) ?? ""
      let before = String(line.prefix(s.column))
      let after  = String(line.suffix(max(0, line.count - e.column)))
      buffer.lines[s.line] = before + text + after
      return XCSourceTextPosition(line: s.line, column: (before as NSString).length + (text as NSString).length)
    } else {
      let first = (buffer.lines[s.line] as? String) ?? ""
      let last  = (buffer.lines[e.line] as? String) ?? ""
      let head = String(first.prefix(s.column))
      let tail = String(last.suffix(max(0, last.count - e.column)))
      let merged = head + text + tail
      for _ in s.line...e.line { buffer.lines.removeObject(at: s.line) }
      buffer.lines.insert(merged, at: s.line)
      return XCSourceTextPosition(line: s.line, column: (head as NSString).length + (text as NSString).length)
    }
  }
}
