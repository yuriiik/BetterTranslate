//
//  AppManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 29.08.2025.
//

import AppKit

class AppManager {
  
  // MARK: - Initialization
  
  init() {
    self.setup()
  }
  
  // MARK: - Public
  
  @Published private(set) var pasteboardText: String = ""
  
  func startMonitoringPasteboard() {
    self.pasteboardMonitor.start()
    self.updateStatusIcon()
  }
  
  func stopMonitoringPasteboard() {
    self.pasteboardMonitor.stop()
    self.updateStatusIcon()
  }
  
  func dismissCurrentTranslationWindow(shouldTurnOff: Bool) {
    if shouldTurnOff {
      self.stopMonitoringPasteboard()
    }
    self.navigationManager.dismissTranslationWindow(shouldClose: false)
  }
  
  // MARK: - Private
  
  private lazy var assemblyManager: AssemblyManager = {
    return AssemblyManager(appManager: self)
  }()
  
  private lazy var navigationManager: NavigationManager = {
    let navigationManager = NavigationManager()
    navigationManager.dataSource = self.assemblyManager
    return navigationManager
  }()
  
  private let appleBooksMetadataCleanupRule = PasteboardMonitor.TextSanitizingRule(
    appBundleId: "com.apple.iBooksX",
    numberOfBottomLinesToRemove: 4)

  private let kindleMetadataCleanupRule = PasteboardMonitor.TextSanitizingRule(
    appBundleId: "com.amazon.Lassen",
    numberOfBottomLinesToRemove: 1)

  private lazy var pasteboardMonitor: PasteboardMonitor = {
    let pasteboardMonitor = PasteboardMonitor()
    pasteboardMonitor.triggerType = .doubleCopy
    pasteboardMonitor.addTextSanitizingRule(self.appleBooksMetadataCleanupRule)
    pasteboardMonitor.addTextSanitizingRule(self.kindleMetadataCleanupRule)
    return pasteboardMonitor
  }()
  
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  private func setup() {
    self.navigationManager.onDismissTranslationWindow = { [weak self] in
      self?.pasteboardMonitor.resetFingerprint()
      self?.pasteboardText = ""
    }
    self.pasteboardMonitor.onTextCopied = { [weak self] copiedText in
      self?.pasteboardText = copiedText
      self?.showTranslationWindow()
    }
    self.setupStatusItem()
  }
  
  private func setupStatusItem() {
    guard let button = self.statusItem.button else { return }
    button.target = self
    button.action = #selector(self.statusItemClicked(_:))
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    button.toolTip = "Better Translate"
  }
  
  private func updateStatusIcon() {
    let symbolName = self.pasteboardMonitor.isRunning ? "globe.europe.africa.fill" : "globe.europe.africa"
    let accessibilityDescription = self.pasteboardMonitor.isRunning ? "Translate On" : "Translate Off"
    self.statusItem.button?.image = NSImage(
      systemSymbolName: symbolName,
      accessibilityDescription: accessibilityDescription)
  }
  
  private func showContextMenu() {
    let menu = NSMenu()
    if self.pasteboardMonitor.isRunning {
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
  
  @objc private func statusItemClicked(_ sender: Any?) {
    guard let event = NSApp.currentEvent else { return }
    switch event.type {
    case .leftMouseUp, .rightMouseUp:
      self.showContextMenu()
    default:
      break
    }
  }
  
  @objc private func toggleTranslationEnabled() {
    if self.pasteboardMonitor.isRunning {
      self.stopMonitoringPasteboard()
    } else {
      self.startMonitoringPasteboard()
    }
  }
  
  @objc private func showTranslationWindow() {
    self.navigationManager.presentTranslationWindow()
  }
  
  @objc private func showSettings() {
    self.navigationManager.dismissTranslationWindow(shouldClose: false)
    self.navigationManager.presentSettingsWindow()
  }
  
  @objc private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}
