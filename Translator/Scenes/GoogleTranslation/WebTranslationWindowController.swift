//
//  WebTranslationWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class WebTranslationWindowController: NSWindowController, PresentableWindowController, NSWindowDelegate, WebTranslationViewControllerDelegate {
  
  // MARK: - Initialization
  
  convenience init(contentViewController: WebTranslationViewController, isHidden: Bool) {
    let window = NSPanel(
      contentRect: .zero,
      styleMask: [.titled, .nonactivatingPanel, .closable, .resizable],
      backing: .buffered,
      defer: false)
    window.title = "Better Translate"
    window.isReleasedWhenClosed = false    
    window.contentViewController = contentViewController
    window.level = .floating
    self.init(window: window)
    window.delegate = self
    let windowFrame = NSRect(
      origin: AppSettings.shared.translationWindowOrigin ?? .zero,
      size: AppSettings.shared.translationWindowSize ?? .zero)
    window.setFrame(windowFrame, display: false)
    if AppSettings.shared.translationWindowOrigin == nil {
      window.center()
    }
    if isHidden {
      window.orderOut(nil)
    } else {
      window.makeKeyAndOrderFront(nil)
    }    
    contentViewController.delegate = self
  }
  
  // MARK: - Overrides
  
  // Disable NSPanel's default "close on Esc" behavior
  override func cancelOperation(_ sender: Any?) {}
  
  // MARK: - PresentableWindowController
  
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
  
  func windowDidEndLiveResize(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return }
    AppSettings.shared.translationWindowOrigin = window.frame.origin
    AppSettings.shared.translationWindowSize = window.frame.size
  }
  
  func windowDidMove(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return }
    AppSettings.shared.translationWindowOrigin = window.frame.origin
  }
  
  // MARK: - WebTranslationViewControllerDelegate
  
  func webTranslationViewControllerWantsToResetPosition() {
    guard let window = self.window else { return }
    window.delegate = nil
    window.center()
    window.delegate = self
    AppSettings.shared.resetTranslationWindowOrigin()
  }
  
  func webTranslationViewControllerWantsToResetSize() {
    AppSettings.shared.resetTranslationWindowSize()
    guard
      let window = self.window,
      let newSize = AppSettings.shared.translationWindowSize
    else { return }
    let oldSize = window.frame.size
    let oldOrigin = window.frame.origin
    let newOrigin = NSPoint(
      x: oldOrigin.x + (oldSize.width - newSize.width) * 0.5,
      y: oldOrigin.y + (oldSize.height - newSize.height) * 0.5)
    let newFrame = NSRect(origin: newOrigin, size: newSize)
    window.delegate = nil
    window.setFrame(newFrame, display: true)
    window.delegate = self
    AppSettings.shared.translationWindowOrigin = newOrigin
  }
}
