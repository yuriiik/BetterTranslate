//
//  AppleTranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa

final class AppleTranslatePresenter: TranslatePresenter {
  override func makeTranslateWindowController(sourceText: String) -> (any TranslateWindowController)? {
    return AppleTranslateWindowController(sourceText: sourceText)
  }
}
