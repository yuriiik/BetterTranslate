//
//  GoogleTranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslatePresenter: TranslationPresenter {
  override func makeTranslationWindowController(sourceText: String) -> (any TranslationWindowController)? {
    guard let viewController = GoogleTranslateViewController.fromStoryboard() else { return nil }
    viewController.translationManager = self.translationManager
    return GoogleTranslateWindowController(contentViewController: viewController)
  }
}
