//
//  AppDelegate.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 18.08.2025.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ notification: Notification) {
    self.translatePresenter.onDismiss = { [weak self] in
      self?.pasteboardWatcher.resetFingerprint()
    }
    self.pasteboardWatcher.onTextCopied = { [weak self] copiedText in
      self?.translatePresenter.present(sourceText: copiedText)
    }
    self.pasteboardWatcher.start()
    self.addStatusItem()
  }

  func applicationWillTerminate(_ notification: Notification) {
    self.pasteboardWatcher.stop()
  }
  
  // MARK: - Private
  
  private let translatePresenter = AppleTranslatePresenter()
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
      self.toggleTranslateEnabled()
    default:
      break
    }
  }
  
  private func toggleTranslateEnabled() {
    if self.pasteboardWatcher.isRunning {
      self.pasteboardWatcher.stop()
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
    menu.addItem(
      withTitle: "Quit",
      action: #selector(self.quitApp),
      keyEquivalent: "q")
    self.statusItem.menu = menu
    self.statusItem.button?.performClick(nil)
    self.statusItem.menu = nil
  }
  
  @objc private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}
