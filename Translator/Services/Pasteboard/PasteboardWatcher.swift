//
//  PasteboardWatcher.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 19.08.2025.
//

import Cocoa

/// Simple polling-based watcher that reacts when the general pasteboard's changeCount increments
/// and contains plain-text. Debounced to avoid double-fires from certain apps.
final class PasteboardWatcher {
  
  // MARK: - Public
  
  struct TextSanitizingRule {
    let appBundleId: String
    let numberOfBottomLinesToRemove: Int
  }
  
  var onTextCopied: ((String) -> Void)?
  
  private(set) var isRunning: Bool = false

  func start() {
    self.stop()
    let timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: true) { [weak self] _ in
      self?.tick()
    }
    self.timer = timer
    RunLoop.current.add(timer, forMode: .common)
    self.lastChangeCount = NSPasteboard.general.changeCount
    self.isRunning = true
  }

  func stop() {
    self.timer?.invalidate()
    self.timer = nil
    self.isRunning = false
  }
  
  func resetFingerprint() {
    self.lastEmittedFingerprint = nil
  }
  
  func addTextSanitizingRule(_ rule: TextSanitizingRule) {
    self.textSanitizingRules[rule.appBundleId] = rule
  }
  
  func removeTextSanitizingRule(_ rule: TextSanitizingRule) {
    self.textSanitizingRules[rule.appBundleId] = nil
  }

  // MARK: - Private
  
  private let interval = 0.15
  private weak var timer: Timer?
  private var lastChangeCount: Int = NSPasteboard.general.changeCount
  private var lastEmittedFingerprint: String?
  private let ignoredPasteboardTypes: Set<NSPasteboard.PasteboardType> = [.fileURL, .tiff]
  private var textSanitizingRules: [String: TextSanitizingRule] = [:]
  private var frontmostApplicationBundleID: String? {
    NSWorkspace.shared.frontmostApplication?.bundleIdentifier
  }
  
  private func tick() {
    let pasteboard = NSPasteboard.general
    let changeCount = pasteboard.changeCount
    guard changeCount != self.lastChangeCount else { return }
    self.lastChangeCount = changeCount

    let pasteboardItems = pasteboard.pasteboardItems ?? []
    let shouldIgnorePasteboardContents = pasteboardItems.contains { pasteboardItem in
      !Set(pasteboardItem.types).isDisjoint(with: self.ignoredPasteboardTypes)
    }
    
    guard
      !shouldIgnorePasteboardContents,
      var pasteboardString = pasteboard.string(forType: .string),
      !pasteboardString.isEmpty
    else { return }
    
    let result = self.sanitizeText(pasteboardString)
    let shouldUpdatePasteboard = result.isTextChanged
    pasteboardString = result.updatedText

    // Debounce: avoid firing repeatedly on identical content bursts.
    let fingerprint = self.fingerprint(of: pasteboardString)
    guard fingerprint != self.lastEmittedFingerprint else { return }
    self.lastEmittedFingerprint = fingerprint
    
    if shouldUpdatePasteboard {
      self.stop()
      pasteboard.clearContents()
      pasteboard.setString(pasteboardString, forType: .string)
      self.start()
    }
    
    self.onTextCopied?(pasteboardString)
  }

  private func fingerprint(of text: String) -> String {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return "\(trimmedText.count)#\(trimmedText.prefix(64))"
  }
  
  private typealias TextCleanupResult = (isTextChanged: Bool, updatedText: String)
  
  private func trimText(_ text: String) -> TextCleanupResult {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let isTextChanged = text != trimmedText
    return (isTextChanged, trimmedText)
  }
  
  private func sanitizeText(_ text: String) -> TextCleanupResult {
    guard
      let bundleID = self.frontmostApplicationBundleID,
      let rule = self.textSanitizingRules[bundleID]
    else {
      return self.trimText(text)
    }
    let newLineCharacter = "\n"
    var lines = text.components(separatedBy: newLineCharacter)
    guard lines.count > rule.numberOfBottomLinesToRemove else {
      return self.trimText(text)
    }
    lines = lines.dropLast(rule.numberOfBottomLinesToRemove)
    let sanitizedText = lines.joined(separator: newLineCharacter)
    return (true, self.trimText(sanitizedText).updatedText)
  }
}
