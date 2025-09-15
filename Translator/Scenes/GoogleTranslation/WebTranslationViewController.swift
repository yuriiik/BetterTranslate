//
//  WebTranslationViewController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import WebKit
import Combine

class WebTranslationViewController: NSViewController, WKNavigationDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var webView: WKWebView!
  
  // MARK: - Actions
  
  @IBAction func reload(_ sender: NSButton) {
    self.loadTranslationWebsite()
  }
  
  @IBAction func close(_ sender: NSButton) {
    self.appManager?.dismissCurrentTranslationWindow(shouldTurnOff: false)
  }

  @IBAction func closeAndTurnOff(_ sender: NSButton) {
    self.appManager?.dismissCurrentTranslationWindow(shouldTurnOff: true)
  }
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.navigationDelegate = self
    self.subscribeToSourceTextUpdates()
    self.subscribeToTranslationWebsiteUpdates()
  }
  
  override func keyDown(with event: NSEvent) {
    guard self.handleCmdV(from: event) else {
      super.keyDown(with: event)
      return
    }
  }
  
  // MARK: - Public
  
  weak var appManager: AppManager?
  
  // MARK: - Private
  
  private enum WebViewLoadingState {
    case notStarted
    case inProgress
    case completed
  }
  
  private var webViewLoadingState: WebViewLoadingState = .notStarted
  
  private var cancellables = Set<AnyCancellable>()
  
  private var sourceText = ""
  private var previousSourceText: String?
  
  private func subscribeToSourceTextUpdates() {
    guard let appManager = self.appManager else { return }
    appManager.$pasteboardText
      .sink { [weak self] pasteboardText in
        self?.sourceText = pasteboardText
        self?.translate()
      }
      .store(in: &self.cancellables)
  }
  
  private func subscribeToTranslationWebsiteUpdates() {
    let publisher = AppSettings.shared.$translationWebsite
    publisher
      .zip(publisher.dropFirst())
      .sink { [weak self] oldValue, newValue in
        guard oldValue != newValue && newValue != nil else { return }
        self?.loadTranslationWebsite(newValue)
      }
      .store(in: &self.cancellables)
  }
  
  private func translate() {
    switch self.webViewLoadingState {
    case .notStarted:
      self.loadTranslationWebsite()
    case .inProgress:
      return
    case .completed:
      self.updateSourceTextOnTranslationWebsite()
    }
  }
  
  private func loadTranslationWebsite(_ translationWebsite: String? = nil) {
    guard
      let translationWebsite = translationWebsite ?? AppSettings.shared.translationWebsite,
      let translationWebsiteURL = URL(string: translationWebsite)
    else { return }
    self.webView.load(URLRequest(url: translationWebsiteURL))
    self.webViewLoadingState = .inProgress
  }
  
  private func updateSourceTextOnTranslationWebsite() {
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
    guard
      let textInputClient = self.view.window?.firstResponder as? NSTextInputClient
    else { return }
    var location = NSNotFound
    var length = 0
    if shouldClear, let previousSourceText = self.previousSourceText {
      location = 0
      length = previousSourceText.count
    }
    let range = NSRange(
      location: location,
      length: length)
    textInputClient.insertText(text, replacementRange: range)
    self.previousSourceText = text
  }
  
  private func handleCmdV(from event: NSEvent) -> Bool {
    let isCmdV =
      event.modifierFlags.contains(.command) &&
      event.charactersIgnoringModifiers?.lowercased() == "v"
    guard isCmdV else { return false }
    return NSApp.sendAction(
      #selector(NSText.paste(_:)),
      to: self.webView,
      from: self)
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.webViewLoadingState = .completed
    self.translate()
  }
}
