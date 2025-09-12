//
//  GoogleTranslationWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslationWindowController: NSWindowController, NSWindowDelegate, NavigationManagerWindowController {
  
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
  
  // MARK: - Overrides
  
  // Disable NSPanel's default "close on Esc" behavior
  override func cancelOperation(_ sender: Any?) {}
  
  // MARK: - NavigationManagerWindowController
  
  var onHide: (() -> Void)?
  
  var onClose: (() -> Void)?
  
  func show() {
    guard let window = self.window else { return }
    if !window.isVisible {
      window.makeKeyAndOrderFront(nil)
    }
  }
  
  func hide(shouldClose: Bool) {
    if shouldClose {
      self.close()
    } else {
      self.window?.orderOut(nil)
      self.onHide?()
    }
  }
  
  // MARK: - NSWindowDelegate
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    self.hide(shouldClose: false)
    return false
  }
  
  func windowWillClose(_ notification: Notification) {
    self.onClose?()
  }
  
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
