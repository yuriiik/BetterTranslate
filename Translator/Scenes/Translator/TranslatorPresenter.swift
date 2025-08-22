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
  
  func show(originalText: String, translatedText: String) {
    if let translatorWindowController = self.translatorWindowController {
      translatorWindowController.update(
        originalText: originalText,
        translatedText: translatedText)
    } else {
      self.translatorWindowController = TranslatorWindowController(
        originalText: originalText,
        translatedText: translatedText)
      self.onShow?()
    }
  }
  
  func close() {
    self.translatorWindowController?.close()
    self.translatorWindowController = nil
    self.onClose?()
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
