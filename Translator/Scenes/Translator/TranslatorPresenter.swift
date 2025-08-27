//
//  TranslatorPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa

final class TranslatorPresenter: CommonTranslatorPresenter {
  override func makeTranslatorWindowController(sourceText: String) -> (any CommonTranslatorWindowController)? {
    return TranslatorWindowController(sourceText: sourceText)
  }
}
