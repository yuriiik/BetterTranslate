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
  
  convenience init(contentViewController: NSViewController) {
    let window = NSPanel(
      contentRect: .zero,
      styleMask: [.titled, .nonactivatingPanel, .closable],
      backing: .buffered,
      defer: false)
    window.isReleasedWhenClosed = false
    window.title = "Better Translate"
    window.contentViewController = contentViewController
    window.level = .floating
    window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
    window.standardWindowButton(.zoomButton)?.isEnabled = false
    self.init(window: window)
    self.window?.delegate = self
    self.updateWindowPosition()
  }
  
  func show() {}
  
  func hide(shouldClose: Bool) {
    self.close()
  }
  
  // MARK: - NSWindowDelegate
  
  func windowWillClose(_ notification: Notification) {
    self.onClose?()
  }
  
  // MARK: - Private
  
  private func updateWindowPosition() {
    DispatchQueue.main.async {
      self.window?.center()
      self.window?.makeKeyAndOrderFront(nil)
    }
  }
}
