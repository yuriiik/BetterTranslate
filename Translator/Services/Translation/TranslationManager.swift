//
//  TranslationManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 29.08.2025.
//

import Cocoa

class TranslationManager {
  
  // MARK: - Public
  
  @Published private(set) var sourceText: String = ""
  
  func start() {
    self.translationPresenter.onDismiss = { [weak self] in
      self?.pasteboardWatcher.resetFingerprint()
      self?.sourceText = ""
    }
    self.pasteboardWatcher.onTextCopied = { [weak self] copiedText in
      self?.sourceText = copiedText
      self?.translationPresenter.present()
    }
    self.pasteboardWatcher.start()
    self.addStatusItem()
  }
  
  func stop() {
    self.pasteboardWatcher.stop()
  }
  
  func dismissCurrentTranslationWindow(shouldTurnOff: Bool) {
    if shouldTurnOff {
      self.pasteboardWatcher.stop()
      self.updateStatusIcon()
      self.translationPresenter.dismissAndClose()
    } else {
      self.translationPresenter.dismiss()
    }
  }
  
  // MARK: - Private
  
  private lazy var translationPresenter: TranslationPresenter = {
    return GoogleTranslationPresenter(translationManager: self)
  }()
  
  private let appleBooksMetadataCleanupRule = PasteboardWatcher.TextSanitizingRule(
    appBundleId: "com.apple.iBooksX",
    numberOfBottomLinesToRemove: 4)

  private let kindleMetadataCleanupRule = PasteboardWatcher.TextSanitizingRule(
    appBundleId: "com.amazon.Lassen",
    numberOfBottomLinesToRemove: 1)

  private lazy var pasteboardWatcher: PasteboardWatcher = {
    let pasteboardWatcher = PasteboardWatcher()
    pasteboardWatcher.triggerType = .doubleCopy
    pasteboardWatcher.addTextSanitizingRule(self.appleBooksMetadataCleanupRule)
    pasteboardWatcher.addTextSanitizingRule(self.kindleMetadataCleanupRule)
    return pasteboardWatcher
  }()
  
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  private func addStatusItem() {
    if let button = self.statusItem.button {
      button.target = self
      button.action = #selector(self.statusItemClicked(_:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
      button.toolTip = "Better Translate"
    }
    self.updateStatusIcon()
  }
  
  @objc private func statusItemClicked(_ sender: Any?) {
    guard let event = NSApp.currentEvent else { return }
    switch event.type {
    case .leftMouseUp, .rightMouseUp:
      self.showContextMenu()
    default:
      break
    }
  }
    
  private func updateStatusIcon() {
    let symbolName = self.pasteboardWatcher.isRunning ? "globe.europe.africa.fill" : "globe.europe.africa"
    let accessibilityDescription = self.pasteboardWatcher.isRunning ? "Translate On" : "Translate Off"
    self.statusItem.button?.image = NSImage(
      systemSymbolName: symbolName,
      accessibilityDescription: accessibilityDescription)
  }
  
  private func showContextMenu() {
    let menu = NSMenu()
    if self.pasteboardWatcher.isRunning {
      menu.addItem(
        withTitle: "Stop",
        target: self,
        action: #selector(self.toggleTranslationEnabled),
        keyEquivalent: "")
    } else {
      menu.addItem(
        withTitle: "Start",
        target: self,
        action: #selector(self.toggleTranslationEnabled),
        keyEquivalent: "")
    }
    menu.addItem(
      withTitle: "Translate Text",
      target: self,
      action: #selector(self.showTranslationWindow),
      keyEquivalent: "")
    menu.addItem(
      withTitle: "Settings...",
      target: self,
      action: #selector(self.showSettings),
      keyEquivalent: "")
    menu.addItem(.separator())
    menu.addItem(
      withTitle: "Quit",
      target: self,
      action: #selector(self.quitApp),
      keyEquivalent: "q")
    self.statusItem.menu = menu
    self.statusItem.button?.performClick(nil)
    self.statusItem.menu = nil
  }
  
  @objc private func toggleTranslationEnabled() {
    if self.pasteboardWatcher.isRunning {
      self.pasteboardWatcher.stop()
      self.translationPresenter.dismissAndClose()
    } else {
      self.pasteboardWatcher.start()
    }
    self.updateStatusIcon()
  }
  
  @objc private func showTranslationWindow() {
    self.translationPresenter.present()
  }
  
  @objc private func showSettings() {
    self.translationPresenter.dismiss()
    self.translationPresenter.presentSettings()
  }
  
  @objc private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}
