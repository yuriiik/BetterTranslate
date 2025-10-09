//
//  AppManager.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 29.08.2025.
//

import AppKit
import Combine

class AppManager {
  
  // MARK: - Initialization
  
  init() {
    self.setup()
  }
  
  // MARK: - Public
  
  @Published private(set) var sourceText: String = ""
  
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
    self.presentationManager.dismissTranslationWindow(shouldClose: false)
  }
  
  // MARK: - Private
  
  private lazy var assemblyManager: AssemblyManager = {
    return AssemblyManager(appManager: self)
  }()
  
  private lazy var presentationManager: PresentationManager = {
    let presentationManager = PresentationManager()
    presentationManager.dataSource = self.assemblyManager
    return presentationManager
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
  
  private lazy var screenCaptureService = ScreenCaptureService()
  
  private lazy var textRecognitionService = TextRecognitionService()
  
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  private func setup() {
    self.presentationManager.onDismissTranslationWindow = { [weak self] in
      self?.pasteboardMonitor.resetFingerprint()
      self?.sourceText = ""
    }
    self.pasteboardMonitor.onTextCopied = { [weak self] copiedText in
      self?.showTranslationWindow()
      self?.sourceText = copiedText      
    }
    self.setupStatusItem()
    self.createShortcutMenu()
    if AppSettings.shared.openSettingsOnAppLaunch {
      self.showSettings()
    }
    self.showTranslationWindow(isInitiallyHidden: true)
  }
  
  private func setupStatusItem() {
    guard let button = self.statusItem.button else { return }
    button.target = self
    button.action = #selector(self.statusItemClicked(_:))
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    button.toolTip = "Better Translate"
  }
  
  private func updateStatusIcon() {
    let symbolName = self.pasteboardMonitor.isRunning ? 
      "globe.europe.africa.fill" :
      "globe.europe.africa"
    self.statusItem.button?.image = NSImage(
      systemSymbolName: symbolName,
      accessibilityDescription: nil)
  }
  
  private func showContextMenu() {
    let menu = NSMenu()
    if self.pasteboardMonitor.isRunning {
      menu.addItem(
        title: String(localized: "Stop Translation"),
        target: self,
        action: #selector(self.toggleTranslationEnabled),
        keyEquivalent: "")
    } else {
      menu.addItem(
        title: String(localized: "Start Translation"),
        target: self,
        action: #selector(self.toggleTranslationEnabled),
        keyEquivalent: "")
    }
    menu.addItem(.separator())
    menu.addItem(
      title: String(localized: "Open Translator"),
      target: self,
      action: #selector(self.showTranslationWindow),
      keyEquivalent: "")
    menu.addItem(
      title: String(localized: "Translate Text on Screen"),
      target: self,
      action: #selector(self.translateTextOnScreen),
      keyEquivalent: "")
    menu.addItem(
      title: String(localized: "Settings..."),
      target: self,
      action: #selector(self.showSettings),
      keyEquivalent: "")
    menu.addItem(.separator())
    menu.addItem(
      title: String(localized: "Quit"),
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
  
  @objc private func showTranslationWindow(isInitiallyHidden: Bool = false) {
    self.presentationManager.presentTranslationWindow(isInitiallyHidden: isInitiallyHidden)
  }

  @objc private func translateTextOnScreen() {
    guard let capturedImage = self.screenCaptureService.getScreenImage() else { return }
    self.textRecognitionService.getTextFromImage(capturedImage) { result in
      switch result {
      case .success(let text):
        DispatchQueue.main.async {
          self.showTranslationWindow()
          self.sourceText = text
        }
      case .failure:
        break
      }
    }
  }
  
  @objc private func showSettings() {
    self.presentationManager.dismissTranslationWindow(shouldClose: false)
    self.presentationManager.presentSettingsWindow()
  }
  
  @objc private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
  
  private func createShortcutMenu() {
    let mainMenu = NSMenu()
    let editItem = NSMenuItem()
    mainMenu.addItem(editItem)
    let editMenu = NSMenu(title: "Edit")
    editItem.submenu = editMenu
    editMenu.addItem(
      title: "Cut",
      action: #selector(NSText.cut(_:)),
      keyEquivalent: "x")
    editMenu.addItem(
      title: "Copy",
      action: #selector(NSText.copy(_:)),
      keyEquivalent: "c")
    editMenu.addItem(
      title: "Paste",
      action: #selector(NSText.paste(_:)),
      keyEquivalent: "v")
    editMenu.addItem(
      title: "Select All",
      action: #selector(NSText.selectAll(_:)),
      keyEquivalent: "a")
    editMenu.addItem(
      title: "Quit",
      target: self,
      action: #selector(self.quitApp),
      keyEquivalent: "q")
    NSApp.mainMenu = mainMenu
  }
}
