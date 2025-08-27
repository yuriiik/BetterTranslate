//
//  GoogleTranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslatePresenter: CommonTranslatorPresenter {
  override func makeTranslatorWindowController(sourceText: String) -> (any CommonTranslatorWindowController)? {
    return GoogleTranslateWindowController(sourceText: sourceText)
  }
}
