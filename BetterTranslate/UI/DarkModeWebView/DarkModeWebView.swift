//
//  DarkModeWebView.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 01.10.2025.
//

import WebKit

class DarkModeWebView: WKWebView {
  
  // MARK: - Initialization
  
  init(frame: CGRect = .zero, isDarkMode: Bool = false) {
    let contentController = WKUserContentController()
    let configuration = WKWebViewConfiguration()
    if isDarkMode {
      contentController.addUserScript(Self.enableDarkModeOnStartScript)
    }
    contentController.addUserScript(Self.darkModeScript)
    configuration.userContentController = contentController
    super.init(frame: frame, configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  func setDarkMode(_ isDarkMode: Bool, shouldReload: Bool = false) {
    self.evaluateJavaScript("DarkMode.isEnabled();") { result, error in
      guard
        let result = result as? Bool,
        isDarkMode != result
      else { return }
      self.removeAllUserScripts()
      if isDarkMode {
        self.addUserScript(Self.enableDarkModeOnStartScript)
        self.addUserScript(Self.darkModeScript)
        self.evaluateJavaScript("DarkMode.enable();")
      } else {
        self.addUserScript(Self.darkModeScript)
        self.evaluateJavaScript("DarkMode.disable();")
      }
      if shouldReload {
        self.reload()
      }
    }
  }
  
  // MARK: - Private
  
  private static var darkModeScript: WKUserScript = {
    .init(
      fileName: "DarkMode",
      fileExtension: "js")
  }()
  
  private static var enableDarkModeOnStartScript: WKUserScript = {
    .init(
      fileName: "EnableDarkModeOnStart",
      fileExtension: "js")
  }()
  
  private var userContentController: WKUserContentController  {
    self.configuration.userContentController
  }
  
  private func removeAllUserScripts() {
    self.userContentController.removeAllUserScripts()
  }
  
  private func addUserScript(_ userScript: WKUserScript) {
    self.userContentController.addUserScript(userScript)
  }
}

private extension WKUserScript {
  convenience init(fileName: String, fileExtension: String) {
    let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    let source = url.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
    self.init(
      source: source,
      injectionTime: .atDocumentStart,
      forMainFrameOnly: false)
  }
}
