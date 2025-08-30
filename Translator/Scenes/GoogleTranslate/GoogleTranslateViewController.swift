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
  
  weak var translationManager: TranslationManager?
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.navigationDelegate = self
    self.translate()
  }
  
  // MARK: - Actions
  
  @IBAction func close(_ sender: NSButton) {
    self.translationManager?.dismissCurrentTranslationWindow(shouldTurnOff: false)
  }

  @IBAction func closeAndTurnOff(_ sender: NSButton) {
    self.translationManager?.dismissCurrentTranslationWindow(shouldTurnOff: true)
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
  
  @IBOutlet private weak var webView: WKWebView!
  
  private var webViewLoadingState: WebViewLoadingState = .notStarted
  
  private let googleTranslateURLString = "https://translate.google.com"
  
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
