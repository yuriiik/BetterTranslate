//
//  AppleTranslationWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa
import SwiftUI

final class AppleTranslationWindowController: NSWindowController, NSWindowDelegate, TranslationWindowController {
  
  // MARK: - Public
  
  var onHide: (() -> Void)?
  var onClose: (() -> Void)?
  
  convenience init(sourceText: String) {
    let translationView = AppleTranslationView()
    let hostingController = NSHostingController(rootView: translationView)
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false)
    window.isReleasedWhenClosed = false
    window.title = "Better Translate"
    window.contentViewController = hostingController
    window.level = .floating
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    self.init(window: window)
    self.window?.delegate = self
    self.updateWindowPosition()
    self.translationViewModel = translationView.viewModel
    self.update(sourceText: sourceText)
  }
  
  func update(sourceText: String) {
    self.translationViewModel?.sourceText = sourceText
  }
  
  func dismiss(shouldClose: Bool) {
    self.close()
  }
  
  // MARK: - NSWindowDelegate
  
  func windowWillClose(_ notification: Notification) {
    self.onClose?()
  }
  
  // MARK: - Private
  
  private var translationViewModel: AppleTranslationViewModel?
  
  private func updateWindowPosition() {
    DispatchQueue.main.async {
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
    }
  }
}
