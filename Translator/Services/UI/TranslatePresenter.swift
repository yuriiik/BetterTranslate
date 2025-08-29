//
//  TranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

protocol TranslateWindowController where Self: NSWindowController {
  var onHide: (() -> Void)? { get set }
  var onClose: (() -> Void)? { get set }
  func update(sourceText: String)
  func dismiss()
}

class TranslatePresenter {
  
  // MARK: - Public
  
  var onPresent: (() -> Void)?
  var onDismiss: (() -> Void)?
  
  init() {
    self.setupKeyDownObserver()
  }
  
  open func makeTranslateWindowController(sourceText: String) -> (any TranslateWindowController)? {
    return nil
  }
  
  func present(sourceText: String) {
    if let translateWindowController = self.translateWindowController {
      translateWindowController.update(sourceText: sourceText)
    } else {
      self.translateWindowController = self.makeTranslateWindowController(sourceText: sourceText)
      self.translateWindowController?.onClose = { [weak self] in
        self?.translateWindowController = nil
        self?.onDismiss?()
      }
      self.translateWindowController?.onHide = { [weak self] in
        self?.onDismiss?()
      }
      self.onPresent?()
    }
  }
  
  func dismiss() {
    self.translateWindowController?.dismiss()
  }
  
  // MARK: - Private
  
  private let escKeyCode = 53
  
  private var translateWindowController: TranslateWindowController?
  
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
