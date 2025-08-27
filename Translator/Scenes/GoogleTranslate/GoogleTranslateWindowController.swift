//
//  GoogleTranslateWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslateWindowController: NSWindowController, CommonTranslatorWindowController {
  
  // MARK: - Public
  
  var onClose: (() -> Void)?
  
  convenience init(sourceText: String) {
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false)
    window.isReleasedWhenClosed = false
    window.title = "Translator"
    window.contentViewController = GoogleTranslateViewController(sourceText: sourceText)
    window.level = .floating
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    self.init(window: window)
    self.updateWindowPosition()
  }
  
  func update(sourceText: String) {}
  
  // MARK: - Private

  private func updateWindowPosition() {
    DispatchQueue.main.async {
      self.window?.setFrame(
        .init(x: 0, y: 0, width: 800, height: 600),
        display: false)
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
    }
  }
}
