//
//  GoogleTranslateViewController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa
import WebKit

class GoogleTranslateViewController: NSViewController, WKUIDelegate {

  // MARK: - Initialization
  
  init(sourceText: String) {
    self.sourceText = sourceText
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = self.webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.translate()
  }
  
  // MARK: - Public
  
  func update(sourceText: String) {
    self.sourceText = sourceText
    self.translate()
  }
  
  // MARK: - Private
  
  private var sourceText: String
  
  private let googleTranslateURLString = "https://translate.google.com/?sl=en&tl=uk&text=%@&op=translate"
  
  private lazy var webView: WKWebView = {
    let webView = WKWebView(
      frame: .zero,
      configuration: WKWebViewConfiguration())
    webView.uiDelegate = self
    return webView
  }()
  
  private func googleTranslateURLString(sourceText: String) -> String {
    String(format: self.googleTranslateURLString, sourceText)
  }
  
  private func translate() {
    guard
      let encodedSourceText = self.sourceText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let googleTranslateURL = URL(string: self.googleTranslateURLString(sourceText: encodedSourceText))
    else { return }
    self.webView.load(URLRequest(url: googleTranslateURL))
  }
}
