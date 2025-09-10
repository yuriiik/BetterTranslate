//
//  NavigationManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import AppKit

protocol NavigationManagerWindowController where Self: NSWindowController {
  var onHide: (() -> Void)? { get set }
  var onClose: (() -> Void)? { get set }
  func show()
  func hide(shouldClose: Bool)
}

protocol NavigationManagerDataSource: AnyObject {
  func makeTranslationWindowController() -> NavigationManagerWindowController?
  func makeSettingsWindowController() -> NavigationManagerWindowController?
}

class NavigationManager {
  
  // MARK: - Initialization
  
  init() {
    self.setupKeyDownObserver()
  }
  
  // MARK: - Public
  
  weak var dataSource: NavigationManagerDataSource?
  
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
  
  private var translationWindowController: NavigationManagerWindowController?
  
  private var settingsWindowController: NavigationManagerWindowController?
  
  private func setupKeyDownObserver() {
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == self.escKeyCode {
        self.dismissTranslationWindow(shouldClose: false)
        return nil
      }
      return event
    }
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return }
      if event.keyCode == self.escKeyCode {
        self.dismissTranslationWindow(shouldClose: false)
      }
    }
  }
}
