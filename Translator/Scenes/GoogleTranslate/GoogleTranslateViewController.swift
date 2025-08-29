//
//  GoogleTranslateViewController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa
import WebKit

class GoogleTranslateViewController: NSViewController, WKNavigationDelegate {

  // MARK: - Public
  
  func translate() {
    switch self.webViewLoadingState {
    case .notStarted:
      self.loadGoogleTranslateWebPage()
    case .inProgress:
      return
    case .completed:
      self.updateSourceTextOnGoogleTranslateWebPage()
    }
  }
  
  // MARK: - View Lifecycle
  
  override func loadView() {
    self.view = self.webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.translate()
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.webViewLoadingState = .completed
    self.translate()
  }
  
  // MARK: - Private
  
  private enum WebViewLoadingState {
    case notStarted
    case inProgress
    case completed
  }
  
  private var webViewLoadingState: WebViewLoadingState = .notStarted
  
  private let googleTranslateURLString = "https://translate.google.com"
  
  private lazy var webView: WKWebView = {
    let webView = WKWebView(
      frame: .zero,
      configuration: WKWebViewConfiguration())
    webView.navigationDelegate = self
    return webView
  }()
  
  private func loadGoogleTranslateWebPage() {
    guard let googleTranslateURL = URL(string: self.googleTranslateURLString) else { return }
    self.webView.load(URLRequest(url: googleTranslateURL))
    self.webViewLoadingState = .inProgress
  }
  
  private func updateSourceTextOnGoogleTranslateWebPage() {
    NSApp.sendAction(
      #selector(NSText.selectAll(_:)),
      to: self.webView,
      from: self)
    NSApp.sendAction(
      #selector(NSText.delete(_:)),
      to: self.webView,
      from: self)
    NSApp.sendAction(
      #selector(NSText.paste(_:)),
      to: self.webView,
      from: self)
  }
}
