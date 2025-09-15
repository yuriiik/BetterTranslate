//
//  AssemblyManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 10.09.2025.
//

class AssemblyManager: PresentationManagerDataSource {
  
  // MARK: - Initialization
  
  init(appManager: AppManager) {
    self.appManager = appManager
  }
  
  // MARK: - Private
  
  private unowned var appManager: AppManager
  
  // MARK: - PresentationManagerDataSource

  //  func makeTranslationWindowController() -> PresentableWindowController? {
  //    let viewModel = AppleTranslationViewModel()
  //    viewModel.appManager = self.appManager
  //    let translationView = AppleTranslationView(viewModel: viewModel)
  //    let hostingController = NSHostingController(rootView: translationView)
  //    return AppleTranslationWindowController(contentViewController: hostingController)
  //  }
  
  func makeTranslationWindowController(isHidden: Bool) -> PresentableWindowController? {
    guard let viewController = WebTranslationViewController.fromStoryboard() else { return nil }
    viewController.appManager = self.appManager
    return WebTranslationWindowController(
      contentViewController: viewController,
      isHidden: isHidden)
  }
  
  func makeSettingsWindowController() -> PresentableWindowController? {
    return SettingsWindowController()
  }
}
