//
//  GoogleTranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslationPresenter: TranslationPresenter {
  override func makeTranslationWindowController(sourceText: String) -> (any TranslationWindowController)? {
    guard let viewController = GoogleTranslationViewController.fromStoryboard() else { return nil }
    viewController.translationManager = self.translationManager
    return GoogleTranslationWindowController(contentViewController: viewController)
  }
}
