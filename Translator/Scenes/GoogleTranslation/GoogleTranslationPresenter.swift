//
//  GoogleTranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

final class GoogleTranslationPresenter: TranslationPresenter {
  override func makeTranslationWindowController() -> TranslationWindowController? {
    guard let viewController = GoogleTranslationViewController.fromStoryboard() else { return nil }
    viewController.appManager = self.appManager
    return GoogleTranslationWindowController(contentViewController: viewController)
  }
}
