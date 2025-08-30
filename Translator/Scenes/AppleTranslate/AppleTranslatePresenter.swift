//
//  AppleTranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa

final class AppleTranslatePresenter: TranslationPresenter {
  override func makeTranslationWindowController(sourceText: String) -> (any TranslationWindowController)? {
    return AppleTranslateWindowController(sourceText: sourceText)
  }
}
