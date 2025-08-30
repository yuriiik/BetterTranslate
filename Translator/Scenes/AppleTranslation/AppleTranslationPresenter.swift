//
//  AppleTranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa

final class AppleTranslationPresenter: TranslationPresenter {
  override func makeTranslationWindowController(sourceText: String) -> (any TranslationWindowController)? {
    return AppleTranslationWindowController(sourceText: sourceText)
  }
}
