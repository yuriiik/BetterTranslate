//
//  TranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

protocol TranslateWindowController where Self: NSWindowController {
  var onClose: (() -> Void)? { get set }
  func update(sourceText: String)
}

class TranslatePresenter {
  
  // MARK: - Public
  
  var onShow: (() -> Void)?
  var onClose: (() -> Void)?
  
  init() {
    self.setupKeyDownObserver()
  }
  
  open func makeTranslateWindowController(sourceText: String) -> (any TranslateWindowController)? {
    return nil
  }
  
  func show(sourceText: String) {
    if let translateWindowController = self.translateWindowController {
      translateWindowController.update(sourceText: sourceText)
    } else {
      self.translateWindowController = self.makeTranslateWindowController(sourceText: sourceText)
      self.translateWindowController?.onClose = { [weak self] in
        self?.close()
      }
      self.onShow?()
    }
  }
  
  func close() {
    // Make sure method is called only once
    if let translateWindowController = self.translateWindowController {
      self.translateWindowController = nil
      translateWindowController.close()
      self.onClose?()
    }
  }
  
  // MARK: - Private
  
  private let escKeyCode = 53
  
  private var translateWindowController: TranslateWindowController?
  
  private func setupKeyDownObserver() {
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return event }
      if event.keyCode == self.escKeyCode {
        self.close()
        return nil
      }
      return event
    }
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else { return }
      if event.keyCode == self.escKeyCode {
        self.close()
      }
    }
  }
}
