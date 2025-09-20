//
//  WebTranslationViewController.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import WebKit
import Combine

protocol WebTranslationViewControllerDelegate: AnyObject {
  func webTranslationViewControllerWantsToResetPosition()
  func webTranslationViewControllerWantsToResetSize()
}

class WebTranslationViewController: NSViewController, WKNavigationDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var errorView: NSView!
  @IBOutlet weak var errorLabel: NSTextField!
  
  // MARK: - Actions
  
  @IBAction func selectAction(_ sender: NSSegmentedControl) {
    switch sender.indexOfSelectedItem {
    case 0:
      // Reload
      self.loadTranslationWebsite()
    case 1:
      // Zoom In
      self.changePageZoom(by: self.zoomStep)
    case 2:
      // Zoom Out
      self.changePageZoom(by: -self.zoomStep)
    case 3:
      // Reset Zoom
      self.changePageZoom(reset: true)
    case 4:
      // Reset Position
      self.delegate?.webTranslationViewControllerWantsToResetPosition()
    case 5:
      // Reset Size
      self.delegate?.webTranslationViewControllerWantsToResetSize()
    default:
      break
    }
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
    self.webView.pageZoom = AppSettings.shared.translationPageZoom
    self.webView.navigationDelegate = self
    self.subscribeToSourceTextUpdates()
    self.subscribeToTranslationWebsiteUpdates()
  }
  
  // MARK: - Public
  
  weak var appManager: AppManager?
  
  weak var delegate: WebTranslationViewControllerDelegate?
  
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
  
  private let zoomStep = 0.1
  
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
    let translationWebsite = translationWebsite ?? AppSettings.shared.translationWebsite
    guard
      let translationWebsite,
      let translationWebsiteURL = URL(string: translationWebsite),
      translationWebsiteURL.isValidWebsite
    else {
      if let translationWebsite, !translationWebsite.isEmpty {
        self.showWebsiteLoadingError(
          website: translationWebsite,
          reason: "Invalid address")
      } else {
        self.showWebsiteLoadingError(reason: "Address is empty")
      }
      return
    }
    self.webView.load(URLRequest(url: translationWebsiteURL))
    self.webViewLoadingState = .inProgress
  }
  
  private func showWebsiteLoadingError(website: String? = nil, reason: String) {
    self.webView.isHidden = true
    self.errorView.isHidden = false
    self.errorLabel.stringValue = 
      "Could not load translation website" +
      (website != nil ? ": \(website!)" : "") +
      "\n\(reason)"
  }
  
  private func hideWebsiteLoadingError() {
    self.webView.isHidden = false
    self.errorView.isHidden = true
    self.errorLabel.stringValue = ""
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
  
  private func changePageZoom(by value: Double? = nil, reset: Bool = false) {
    if let value {
      self.webView.pageZoom += value
    } else if reset {
      self.webView.pageZoom = 1
    }
    AppSettings.shared.translationPageZoom = self.webView.pageZoom
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.hideWebsiteLoadingError()
    self.webViewLoadingState = .completed
    self.translate()    
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
    self.showWebsiteLoadingError(
      website: error.failingURLString,
      reason: error.localizedDescription)
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
    self.showWebsiteLoadingError(
      website: error.failingURLString,
      reason: error.localizedDescription)
  }
}
