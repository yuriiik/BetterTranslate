//
//  TranslatorPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa

final class TranslatorPresenter {
  
  // MARK: - Public
  
  var onShow: (() -> Void)?
  var onClose: (() -> Void)?
  
  init() {
    self.setupKeyDownObserver()
  }
  
  func show(sourceText: String) {
    if let translatorWindowController = self.translatorWindowController {
      translatorWindowController.update(sourceText: sourceText)
    } else {
      self.translatorWindowController = TranslatorWindowController(sourceText: sourceText)
      self.translatorWindowController?.onClose = { [weak self] in
        self?.close()
      }
      self.onShow?()
    }
  }
  
  func close() {
    // Make sure method is called only once
    if let translatorWindowController = self.translatorWindowController {
      self.translatorWindowController = nil
      translatorWindowController.close()
      self.onClose?()
    }
  }
  
  // MARK: - Private
  
  private let escKeyCode = 53
  
  private var translatorWindowController: TranslatorWindowController?
  
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
