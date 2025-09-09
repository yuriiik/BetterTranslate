//
//  AppleTranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import SwiftUI

final class AppleTranslationPresenter: TranslationPresenter {
  override func makeTranslationWindowController() -> TranslationWindowController? {
    let viewModel = AppleTranslationViewModel()
    viewModel.appManager = self.appManager
    let translationView = AppleTranslationView(viewModel: viewModel)
    let hostingController = NSHostingController(rootView: translationView)
    return AppleTranslationWindowController(contentViewController: hostingController)
  }
}
