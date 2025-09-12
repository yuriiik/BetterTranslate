//
//  PresentationManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import AppKit

protocol PresentableWindowController where Self: NSWindowController {
  var onHide: (() -> Void)? { get set }
  var onClose: (() -> Void)? { get set }
  var isVisible: Bool { get }
  func contains(_ point: NSPoint) -> Bool
  func show()
  func hide(shouldClose: Bool)
}

extension PresentableWindowController {
  var isVisible: Bool {
    self.window?.isVisible == true
  }
  
  func contains(_ point: NSPoint) -> Bool {
    self.window?.frame.contains(point) == true
  }
}

protocol PresentationManagerDataSource: AnyObject {
  func makeTranslationWindowController() -> PresentableWindowController?
  func makeSettingsWindowController() -> PresentableWindowController?
}

class PresentationManager {
  
  // MARK: - Public
  
  weak var dataSource: PresentationManagerDataSource?
  
  var onPresentTranslationWindow: (() -> Void)?
  
  var onDismissTranslationWindow: (() -> Void)?
  
  func presentTranslationWindow() {
    if let translationWindowController = self.translationWindowController {
      translationWindowController.show()
    } else if let translationWindowController = self.dataSource?.makeTranslationWindowController() {
      translationWindowController.onClose = { [weak self] in
        self?.translationWindowController = nil
        self?.onDismissTranslationWindow?()
      }
      translationWindowController.onHide = { [weak self] in
        self?.onDismissTranslationWindow?()
      }
      self.translationWindowController = translationWindowController
      self.onPresentTranslationWindow?()
    }
    self.startKeyDownMonitor()
    self.startMouseClickMonitor()
  }
  
  func dismissTranslationWindow(shouldClose: Bool) {
    self.translationWindowController?.hide(shouldClose: shouldClose)
    self.stopKeyDownMonitor()
    self.stopMouseClickMonitor()
  }
  
  func presentSettingsWindow() {
    if let settingsWindowController = self.settingsWindowController {
      settingsWindowController.show()
    } else if let settingsWindowController = self.dataSource?.makeSettingsWindowController() {
      settingsWindowController.onClose = { [weak self] in
        self?.settingsWindowController = nil
      }
      self.settingsWindowController = settingsWindowController
    }
  }
  
  func dismissSettingsWindow() {
    self.settingsWindowController?.hide(shouldClose: true)
  }
  
  // MARK: - Private
  
  private let escKeyCode = 53
  
  private var translationWindowController: PresentableWindowController?
  private var settingsWindowController: PresentableWindowController?
  
  private var localKeyDownMonitor: Any?
  private var globalKeyDownMonitor: Any?
  private var mouseClickMonitor: Any?
  
  private func startKeyDownMonitor() {
    guard
      AppSettings.escClosesTranslationWindow,
      self.localKeyDownMonitor == nil ||
      self.globalKeyDownMonitor == nil
    else { return }
    self.stopKeyDownMonitor()
    self.localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == self.escKeyCode {
        self.dismissTranslationWindow(shouldClose: false)
        return nil
      }
      return event
    }
    self.globalKeyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return }
      if event.keyCode == self.escKeyCode {
        self.dismissTranslationWindow(shouldClose: false)
      }
    }
  }
  
  private func stopKeyDownMonitor() {
    self.removeMonitor(&self.localKeyDownMonitor)
    self.removeMonitor(&self.globalKeyDownMonitor)
  }

  private func startMouseClickMonitor() {
    guard
      AppSettings.clickOutsideClosesTranslationWindow,
      self.mouseClickMonitor == nil
    else { return }
    self.mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
      guard
        let self = self,
        let translationWindowController = self.translationWindowController,
        translationWindowController.isVisible
      else { return }
      let clickLocation = event.locationInScreenCoordinates
      if !translationWindowController.contains(clickLocation) {
        self.dismissTranslationWindow(shouldClose: false)
      }
    }
  }

  private func stopMouseClickMonitor() {
    self.removeMonitor(&self.mouseClickMonitor)
  }
  
  private func removeMonitor(_ monitor: inout Any?) {
    monitor.map { NSEvent.removeMonitor($0) }
    monitor = nil
  }
}
