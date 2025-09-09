//
//  AppleTranslationWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import AppKit

final class AppleTranslationWindowController: NSWindowController, NSWindowDelegate, TranslationWindowController {
  
  // MARK: - Initialization
  
  convenience init(contentViewController: NSViewController) {
    let window = NSPanel(
      contentRect: .zero,
      styleMask: [.titled, .nonactivatingPanel, .closable],
      backing: .buffered,
      defer: false)
    window.title = "Better Translate"
    window.isReleasedWhenClosed = false    
    window.contentViewController = contentViewController
    window.level = .floating
    self.init(window: window)
    self.window?.delegate = self
    self.updateWindowPosition()
  }
  
  // MARK: - TranslationWindowController
  
  var onHide: (() -> Void)?
  
  var onClose: (() -> Void)?
  
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
