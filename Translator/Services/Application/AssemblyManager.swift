//
//  AssemblyManager.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 10.09.2025.
//

class AssemblyManager: NavigationManagerDataSource {
  
  // MARK: - Initialization
  
  init(appManager: AppManager) {
    self.appManager = appManager
  }
  
  // MARK: - Private
  
  private unowned var appManager: AppManager
  
  // MARK: - NavigationManagerDataSource

  //  func makeTranslationWindowController() -> NavigationManagerWindowController? {
  //    let viewModel = AppleTranslationViewModel()
  //    viewModel.appManager = self.appManager
  //    let translationView = AppleTranslationView(viewModel: viewModel)
  //    let hostingController = NSHostingController(rootView: translationView)
  //    return AppleTranslationWindowController(contentViewController: hostingController)
  //  }
  
  func makeTranslationWindowController() -> NavigationManagerWindowController? {
    guard let viewController = GoogleTranslationViewController.fromStoryboard() else { return nil }
    viewController.appManager = self.appManager
    return GoogleTranslationWindowController(contentViewController: viewController)
  }
  
  func makeSettingsWindowController() -> NavigationManagerWindowController? {
    return SettingsWindowController()
  }
}
