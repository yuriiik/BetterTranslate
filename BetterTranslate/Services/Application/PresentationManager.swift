//
//  PresentationManager.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import AppKit

@MainActor
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

@MainActor
protocol PresentationManagerDataSource: AnyObject {
  func makeTranslationWindowController(isHidden: Bool) -> PresentableWindowController?
  func makeSettingsWindowController() -> PresentableWindowController?
}

@MainActor
class PresentationManager {
  
  // MARK: - Public
  
  weak var dataSource: PresentationManagerDataSource?
  
  var onPresentTranslationWindow: (() -> Void)?
  
  var onDismissTranslationWindow: (() -> Void)?
  
  func presentTranslationWindow(isInitiallyHidden: Bool = false) {
    var isExistingWindowController = false
    if let translationWindowController = self.translationWindowController {
      translationWindowController.show()
      isExistingWindowController = true
    } else if let translationWindowController = self.dataSource?.makeTranslationWindowController(isHidden: isInitiallyHidden) {
      translationWindowController.onClose = { [weak self] in
        self?.translationWindowController = nil
        self?.stopInputMonitoring()
        self?.onDismissTranslationWindow?()
      }
      translationWindowController.onHide = { [weak self] in
        self?.stopInputMonitoring()
        self?.onDismissTranslationWindow?()
      }
      self.translationWindowController = translationWindowController
      self.onPresentTranslationWindow?()
    }
    if isExistingWindowController || !isInitiallyHidden {
      self.startInputMonitoring()
    }
  }
  
  func dismissTranslationWindow(shouldClose: Bool) {
    self.translationWindowController?.hide(shouldClose: shouldClose)
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
  private var mouseClickMonitor: Any?
  
  private func startKeyDownMonitoring() {
    guard
      AppSettings.shared.escClosesTranslationWindow &&
      self.localKeyDownMonitor == nil
    else { return }
    self.localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == self.escKeyCode {
        self.dismissTranslationWindow(shouldClose: false)
        return nil
      }
      return event
    }
  }
  
  private func stopKeyDownMonitoring() {
    self.removeMonitor(&self.localKeyDownMonitor)
  }

  private func startMouseClickMonitoring() {
    guard
      AppSettings.shared.clickOutsideClosesTranslationWindow &&
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

  private func stopMouseClickMonitoring() {
    self.removeMonitor(&self.mouseClickMonitor)
  }
  
  private func startInputMonitoring() {
    self.startKeyDownMonitoring()
    self.startMouseClickMonitoring()
  }
  
  private func stopInputMonitoring() {
    self.stopKeyDownMonitoring()
    self.stopMouseClickMonitoring()
  }
  
  private func removeMonitor(_ monitor: inout Any?) {
    monitor.map { NSEvent.removeMonitor($0) }
    monitor = nil
  }
}
