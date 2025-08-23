//
//  TranslatorViewModel.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Foundation
import Translation

class TranslatorViewModel: ObservableObject {
  @Published var originalText = ""
  @Published var translatedText = ""
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
  
  private var settings = Settings()
  
  init() {
    self.prepareSupportedLanguages()
    self.sourceLanguage = self.settings.sourceLanguage
    self.targetLanguage = self.settings.targetLanguage
  }
  
  func prepareSupportedLanguages() {
    Task {
      let supportedLanguages = await LanguageAvailability().supportedLanguages
      self.availableLanguages = supportedLanguages.map {
        AvailableLanguage(localeLanguage: $0)
      }.sorted()
    }
  }
}

struct AvailableLanguage: Identifiable, Hashable, Comparable {
  var id: Self { self }
  let localeLanguage: Locale.Language
  
  func localizedName() -> String {
    let shortName = self.shortName()
    guard let localizedName = Locale.current.localizedString(forLanguageCode: shortName) else {
      return "Unknown language code"
    }
    return "\(localizedName) (\(shortName))"
  }
  
  private func shortName() -> String {
    "\(self.localeLanguage.languageCode ?? "")-\(self.localeLanguage.region ?? "")"
  }
  
  static func <(lhs: AvailableLanguage, rhs: AvailableLanguage) -> Bool {
    return lhs.localizedName() < rhs.localizedName()
  }
}
