//
//  TranslatorWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa
import SwiftUI

final class TranslatorWindowController: NSWindowController {
  
  // MARK: - Public
  
  convenience init(sourceText: String) {
    let translatorView = TranslatorView()
    let hostingController = NSHostingController(rootView: translatorView)
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false)
    window.isReleasedWhenClosed = false
    window.title = "Translator"
    window.contentViewController = hostingController
    window.level = .floating
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    self.init(window: window)
    self.updateWindowPosition()
    self.translatorViewModel = translatorView.viewModel
    self.update(sourceText: sourceText)
  }
  
  func update(sourceText: String) {
    self.translatorViewModel?.sourceText = sourceText
  }
  
  // MARK: - Private
  
  private var translatorViewModel: TranslatorViewModel?
  
  private func updateWindowPosition() {
    DispatchQueue.main.async {
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
    }
  }
}
