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
    return AppleTranslationPresenter(translationManager: self)
  }()
  
  private let pasteboardWatcher = PasteboardWatcher()
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
    case .rightMouseUp:
      self.showContextMenu()
    case .leftMouseUp:
      self.toggleTranslationEnabled()
    default:
      break
    }
  }
  
  private func toggleTranslationEnabled() {
    if self.pasteboardWatcher.isRunning {
      self.pasteboardWatcher.stop()
      self.translationPresenter.dismissAndClose()
    } else {
      self.pasteboardWatcher.start()
    }
    self.updateStatusIcon()
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
    let menuItem = menu.addItem(
      withTitle: "Quit",
      action: #selector(self.quitApp),
      keyEquivalent: "q")
    menuItem.target = self
    self.statusItem.menu = menu
    self.statusItem.button?.performClick(nil)
    self.statusItem.menu = nil
  }
  
  @objc private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}
