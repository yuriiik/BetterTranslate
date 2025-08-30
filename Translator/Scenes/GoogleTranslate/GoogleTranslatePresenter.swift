//
//  GoogleTranslatePresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa

final class GoogleTranslatePresenter: TranslatePresenter {
  override func makeTranslateWindowController(sourceText: String) -> (any TranslateWindowController)? {
    guard let viewController = GoogleTranslateViewController.fromStoryboard() else { return nil }
    viewController.translateManager = self.translateManager
    return GoogleTranslateWindowController(contentViewController: viewController)
  }
}
