//
//  SettingsWindowController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate, TranslationWindowController {
  
  // MARK: - Initialization
  
  convenience init() {
    let settingsView = SettingsView()
    let hostingController = NSHostingController(rootView: settingsView)
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false)
    window.title = "Settings"
    window.isReleasedWhenClosed = false
    window.contentViewController = hostingController
    self.init(window: window)
    self.window?.delegate = self
    self.updateWindowPosition()
  }
  
  // MARK: - TranslationWindowController
  
  var onHide: (() -> Void)?
  
  var onClose: (() -> Void)?
  
  func show() {
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  func hide(shouldClose: Bool) {}
  
  // MARK: - NSWindowDelegate
  
  func windowWillClose(_ notification: Notification) {
    self.onClose?()
  }
  
  // MARK: - Private
  
  private func updateWindowPosition() {
    DispatchQueue.main.async {
      if let contentView = self.window?.contentView {
        contentView.layoutSubtreeIfNeeded()
        self.window?.setContentSize(contentView.fittingSize)
      }
      self.window?.center()
      self.show()
    }
  }
}
