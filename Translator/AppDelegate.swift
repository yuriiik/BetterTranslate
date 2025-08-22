//
//  AppDelegate.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 18.08.2025.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
  private let translatorPresenter = TranslatorPresenter()
  private let pasteboardWatcher = PasteboardWatcher()
  private let translateService: TranslateService = GoogleTranslateService()

  func applicationDidFinishLaunching(_ notification: Notification) {
    self.translatorPresenter.onClose = { [weak self] in
      self?.pasteboardWatcher.resetFingerprint()
    }
    self.pasteboardWatcher.onTextCopied = { [weak self] copiedText in
      guard let self else { return }
      self.translatorPresenter.show(
        originalText: copiedText,
        translatedText: "Translating...")
      self.translateService.translateText(copiedText, from: "en", to: "uk") { translatedText in
        guard let translatedText else { return }
        DispatchQueue.main.async {
          self.translatorPresenter.show(
            originalText: copiedText,
            translatedText: translatedText)
        }
      }
    }
    self.pasteboardWatcher.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    self.pasteboardWatcher.stop()
  }
}
