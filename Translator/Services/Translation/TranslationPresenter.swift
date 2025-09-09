//
//  TranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import AppKit

protocol TranslationWindowController where Self: NSWindowController {
  var onHide: (() -> Void)? { get set }
  var onClose: (() -> Void)? { get set }
  func show()
  func hide(shouldClose: Bool)
}

class TranslationPresenter {
  
  // MARK: - Public
  
  var onPresent: (() -> Void)?
  var onDismiss: (() -> Void)?
  
  init(appManager: AppManager) {
    self.appManager = appManager
    self.setupKeyDownObserver()
  }
  
  open func makeTranslationWindowController() -> TranslationWindowController? {
    return nil
  }
  
  func present() {
    if let translationWindowController = self.translationWindowController {
      translationWindowController.show()
    } else {
      self.translationWindowController = self.makeTranslationWindowController()
      self.translationWindowController?.onClose = { [weak self] in
        self?.translationWindowController = nil
        self?.onDismiss?()
      }
      self.translationWindowController?.onHide = { [weak self] in
        self?.onDismiss?()
      }
      self.onPresent?()
    }
  }
  
  func dismiss() {
    self.translationWindowController?.hide(shouldClose: false)
  }
  
  func dismissAndClose() {
    self.translationWindowController?.hide(shouldClose: true)
  }
  
  func presentSettings() {
    if let settingsWindowController = self.settingsWindowController {
      settingsWindowController.show()
    } else {
      self.settingsWindowController = SettingsWindowController()
      self.settingsWindowController?.onClose = { [weak self] in
        self?.settingsWindowController = nil
      }
    }
  }
  
  // MARK: - Private
  
  private(set) weak var appManager: AppManager?
  
  private let escKeyCode = 53
  
  private var translationWindowController: TranslationWindowController?
  
  private var settingsWindowController: TranslationWindowController?
  
  private func setupKeyDownObserver() {
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == self.escKeyCode {
        self.dismiss()
        return nil
      }
      return event
    }
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return }
      if event.keyCode == self.escKeyCode {
        self.dismiss()
      }
    }
  }
}
