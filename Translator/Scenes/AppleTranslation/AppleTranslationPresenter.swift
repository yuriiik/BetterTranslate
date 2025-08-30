//
//  AppleTranslationPresenter.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Cocoa
import SwiftUI

final class AppleTranslationPresenter: TranslationPresenter {
  override func makeTranslationWindowController() -> (any TranslationWindowController)? {
    let viewModel = AppleTranslationViewModel()
    viewModel.translationManager = self.translationManager
    let translationView = AppleTranslationView(viewModel: viewModel)
    let hostingController = NSHostingController(rootView: translationView)
    return AppleTranslationWindowController(contentViewController: hostingController)
  }
}
