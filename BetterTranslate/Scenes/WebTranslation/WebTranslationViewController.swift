//
//  WebTranslationViewController.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 27.08.2025.
//

import WebKit
import Combine

@MainActor
protocol WebTranslationViewControllerDelegate: AnyObject {
  func webTranslationViewControllerWantsToResetPosition()
  func webTranslationViewControllerWantsToResetSize()
}

class WebTranslationViewController: NSViewController, WKNavigationDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var webViewContainer: NSView!
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
    self.setupWebView()
    self.subscribeToSourceTextUpdates()
    self.subscribeToTranslationWebsiteUpdates()
    self.subscribeToCustomDarkModeUpdates()
    self.subscribeToInterfaceThemeUpdates()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    self.updateWindowTitle()
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    self.hasEverBeenVisible = true
  }
  
  deinit {
    self.unsubscribeFromInterfaceThemeUpdates()
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
  
  private weak var webView: DarkModeWebView!
  
  private var hasEverBeenVisible = false
  
  private var isTranslationWebsiteChanged = false
  
  private var cancellables = Set<AnyCancellable>()
  
  private var sourceText = ""
  
  private var previousSourceText: String?
  
  private let zoomStep = 0.1
  
  private var isSystemDarkModeEnabled: Bool {
    self.view.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
  }
  
  private var isCustomDarkModeEnabled: Bool {
    switch AppSettings.shared.darkMode {
    case .websiteDriven:
      return false
    case .customMirrorSystem:
      return self.isSystemDarkModeEnabled
    case .customAlwaysOn:
      return true
    }
  }
  
  @objc private func updateWebViewDarkMode() {
    // If dark mode was changed while the webpage wasn't visible yet, reload it.
    // Otherwise, you may see flashing white/black colors when the webpage first appears.
    self.webView.setDarkMode(
      self.isCustomDarkModeEnabled,
      shouldReload: !self.hasEverBeenVisible)
  }
  
  private func setupWebView() {
    let webView = DarkModeWebView(isDarkMode: self.isCustomDarkModeEnabled)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.pageZoom = AppSettings.shared.translationPageZoom
    webView.navigationDelegate = self
    self.webViewContainer.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: self.webViewContainer.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: self.webViewContainer.trailingAnchor),
      webView.topAnchor.constraint(equalTo: self.webViewContainer.topAnchor),
      webView.bottomAnchor.constraint(equalTo: self.webViewContainer.bottomAnchor)
    ])
    self.webView = webView
  }
  
  private func subscribeToSourceTextUpdates() {
    guard let appManager = self.appManager else { return }
    appManager.$sourceText
      .sink { [weak self] sourceText in
        self?.sourceText = sourceText
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
        self?.isTranslationWebsiteChanged = true
        self?.updateWindowTitle(translationWebsite: newValue)
        self?.loadTranslationWebsite(newValue)
      }
      .store(in: &self.cancellables)
  }
  
  private func subscribeToCustomDarkModeUpdates() {
    AppSettings.shared.$darkMode
      .dropFirst()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] darkMode in
        self?.updateWebViewDarkMode()
      }
      .store(in: &self.cancellables)
  }
  
  private func subscribeToInterfaceThemeUpdates() {
    DistributedNotificationCenter.default().addObserver(
        self,
        selector: #selector(updateWebViewDarkMode),
        name: .AppleInterfaceThemeChangedNotification,
        object: nil
    )
  }
  
  nonisolated
  private func unsubscribeFromInterfaceThemeUpdates() {
    DistributedNotificationCenter.default().removeObserver(
      self,
      name: .AppleInterfaceThemeChangedNotification,
      object: nil)
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
          reason: String(localized: "Invalid address"))
      } else {
        self.showWebsiteLoadingError(reason: String(localized: "Address is empty"))
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
      String(localized: "Unable to open the translation website") +
      (website != nil ? ": \(website!)" : "") +
      "\n\(reason)"
  }
  
  private func hideWebsiteLoadingError() {
    self.webView.isHidden = false
    self.errorView.isHidden = true
    self.errorLabel.stringValue = ""
  }
  
  private func updateSourceTextOnTranslationWebsite() {
    // When translation website is changed in Settings, the first translation
    // sometimes fails because source text is not inserted into the input field.
    // Inserting text with small delay seems to fix the issue.
    if self.isTranslationWebsiteChanged && !self.sourceText.isEmpty {
      self.isTranslationWebsiteChanged = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.insertTextIntoFocusedField(self.sourceText, shouldClear: true)
      }
    } else {
      self.insertTextIntoFocusedField(self.sourceText, shouldClear: true)
    }
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
  
  private func changePageZoom(by value: Double? = nil, reset: Bool = false) {
    if let value {
      self.webView.pageZoom += value
    } else if reset {
      self.webView.pageZoom = 1
    }
    AppSettings.shared.translationPageZoom = self.webView.pageZoom
  }
  
  private func updateWindowTitle(translationWebsite: String? = nil) {
    let translationWebsite = translationWebsite ?? AppSettings.shared.translationWebsite ?? ""
    self.view.window?.title = "Better Translate" + (translationWebsite.isEmpty ? "" : " (\(translationWebsite))")
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
    self.webViewLoadingState = .notStarted
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
    self.showWebsiteLoadingError(
      website: error.failingURLString,
      reason: error.localizedDescription)
    self.webViewLoadingState = .notStarted
  }
}
