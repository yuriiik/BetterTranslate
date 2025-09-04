//
//  GoogleTranslationViewController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import Cocoa
import WebKit
import Combine

class GoogleTranslationViewController: NSViewController, WKNavigationDelegate {

  // MARK: - Public
  
  weak var translationManager: TranslationManager?
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.navigationDelegate = self
    self.subscribeToSourceTextUpdates()
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
  
  private var cancellables = Set<AnyCancellable>()
  
  private var sourceText = ""
  private var previousSourceText: String?
  
  private func subscribeToSourceTextUpdates() {
    guard let translationManager = self.translationManager else { return }
    translationManager.$sourceText
      .sink { [weak self] sourceText in
        self?.sourceText = sourceText
        self?.translate()
      }
      .store(in: &self.cancellables)
  }
  
  private func translate() {
    switch self.webViewLoadingState {
    case .notStarted:
      self.loadGoogleTranslateWebPage()
    case .inProgress:
      return
    case .completed:
      self.updateSourceTextOnGoogleTranslateWebPage()
    }
  }
  
  private func loadGoogleTranslateWebPage() {
    guard let googleTranslateURL = URL(string: self.googleTranslateURLString) else { return }
    self.webView.load(URLRequest(url: googleTranslateURL))
    self.webViewLoadingState = .inProgress
  }
  
  private func updateSourceTextOnGoogleTranslateWebPage() {
    self.clearFocusedField()
    self.insertTextIntoFocusedField(self.sourceText)
  }
  
  private func clearFocusedField() {
    NSApp.sendAction(
      #selector(NSText.selectAll(_:)),
      to: self.webView,
      from: self)
    NSApp.sendAction(
      #selector(NSText.delete(_:)),
      to: self.webView,
      from: self)
  }
  
  private func insertTextIntoFocusedField(_ text: String, shouldClear: Bool = false) {
    guard let textInputClient = self.view.window?.firstResponder as? NSTextInputClient else { return }
    var location = NSNotFound
    var length = 0
    if shouldClear, let previousSourceText = self.previousSourceText {
      location = 0
      length = previousSourceText.count
    }
    let range = NSRange(location: location, length: length)
    textInputClient.insertText(text, replacementRange: range)
    self.previousSourceText = text
  }
}
