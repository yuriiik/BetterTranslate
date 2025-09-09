//
//  AppleTranslationViewModel.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Combine
import Translation
import NaturalLanguage

class AppleTranslationViewModel: ObservableObject {
  
  // MARK: - Public
  
  @Published var availableLanguages: [AvailableLanguage] = []
  
  @Published var sourceLanguage: Locale.Language? {
    didSet {
      self.settings.sourceLanguage = self.sourceLanguage
    }
  }
  
  @Published var targetLanguage: Locale.Language? {
    didSet {
      self.settings.targetLanguage = self.targetLanguage
    }
  }
  
  @Published var sourceText = "" {
    didSet {
      self.autodetectSourceLanguageIfNecessary()
    }
  }
  
  @Published var targetText = ""
  
  var appManager: AppManager? {
    didSet {
      self.subscribeToSourceTextUpdates()
    }
  }
  
  init() {
    self.prepareSupportedLanguages()
    self.sourceLanguage = self.settings.sourceLanguage
    self.targetLanguage = self.settings.targetLanguage
  }
  
  func resetSelectedLanguages() {
    self.sourceLanguage = nil
    self.targetLanguage = nil
  }
  
  func close() {
    self.appManager?.dismissCurrentTranslationWindow(shouldTurnOff: false)
  }
  
  func closeAndTurnOff() {
    self.appManager?.dismissCurrentTranslationWindow(shouldTurnOff: true)
  }
  
  // MARK: - Private
  
  private var settings = AppSettings()
  
  private var cancellables = Set<AnyCancellable>()
  
  private func subscribeToSourceTextUpdates() {
    guard let appManager = self.appManager else { return }
    appManager.$pasteboardText
      .sink { [weak self] pasteboardText in
        self?.sourceText = pasteboardText
      }
      .store(in: &self.cancellables)
  }

  private func prepareSupportedLanguages() {
    Task {
      let supportedLanguages = await LanguageAvailability().supportedLanguages
      self.availableLanguages = supportedLanguages.map {
        AvailableLanguage(localeLanguage: $0)
      }.sorted()
    }
  }
  
  private func autodetectSourceLanguageIfNecessary() {
    guard
      self.sourceLanguage == nil,
      let dominantLanguage = NLLanguageRecognizer.dominantLanguage(for: self.sourceText)
    else { return }
    self.sourceLanguage = self.availableLanguages
      .map { $0.localeLanguage }
      .first { $0.languageCode?.identifier == dominantLanguage.rawValue }
  }
}

struct AvailableLanguage: Identifiable, Hashable, Comparable {
  var id: Self { self }
  let localeLanguage: Locale.Language
  let localizedName: String
  
  init(localeLanguage: Locale.Language) {
    self.localeLanguage = localeLanguage
    let shortName = "\(localeLanguage.languageCode ?? "")-\(localeLanguage.region ?? "")"
    if let localizedName = Locale.current.localizedString(forLanguageCode: shortName) {
      self.localizedName = "\(localizedName) (\(shortName))"
    } else {
      self.localizedName = "Unknown language code"
    }
  }
  
  static func <(lhs: AvailableLanguage, rhs: AvailableLanguage) -> Bool {
    return lhs.localizedName < rhs.localizedName
  }
}
