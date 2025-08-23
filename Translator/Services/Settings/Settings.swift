//
//  Settings.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 23.08.2025.
//

import Foundation

struct Settings {
  
  // MARK: - Public
  
  var sourceLanguage: Locale.Language? {
    get {
      self.getLanguage(for: self.sourceLanguageKey)
    }
    set {
      self.setLanguage(newValue, for: self.sourceLanguageKey)
    }
  }
  
  var targetLanguage: Locale.Language? {
    get {
      self.getLanguage(for: self.targetLanguageKey)
    }
    set {
      self.setLanguage(newValue, for: self.targetLanguageKey)
    }
  }
  
  // MARK: - Private
  
  private let sourceLanguageKey = "com.yuriik.BetterTranslate.SourceLanguage"
  private let targetLanguageKey = "com.yuriik.BetterTranslate.TargetLanguage"
  
  private func getLanguage(for key: String) -> Locale.Language? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(Locale.Language.self, from: data)
  }
  
  private func setLanguage(_ language: Locale.Language?, for key: String) {
    if let language {
      guard let data = try? JSONEncoder().encode(language) else { return }
      UserDefaults.standard.set(data, forKey: key)
    } else {
      UserDefaults.standard.removeObject(forKey: key)
    }
  }
}
