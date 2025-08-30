//
//  GoogleTranslationWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslationWindowController: NSWindowController, NSWindowDelegate, TranslationWindowController {
  
  // MARK: - Public
  
  var onHide: (() -> Void)?
  var onClose: (() -> Void)?
  
  convenience init(contentViewController: GoogleTranslationViewController) {
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable],
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
  
  func update(sourceText: String) {
    guard
      let window = self.window,
      let translationViewController = self.contentViewController as? GoogleTranslationViewController
    else { return }
    translationViewController.translate()
    if !window.isVisible {
      window.makeKeyAndOrderFront(nil)
    }
  }
  
  func dismiss(shouldClose: Bool) {
    if shouldClose {
      self.close()
    } else {
      self.window?.orderOut(nil)
      self.onHide?()
    }
  }
  
  // MARK: - NSWindowDelegate
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    self.dismiss(shouldClose: false)
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
