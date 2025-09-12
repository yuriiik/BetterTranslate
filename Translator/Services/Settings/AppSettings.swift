//
//  AppSettings.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 23.08.2025.
//

import Foundation

struct AppSettings {
  
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
  
  static var escClosesTranslationWindow: Bool {
    get {
      UserDefaults.standard.bool(forKey: self.escClosesTranslationWindowKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: self.escClosesTranslationWindowKey)
    }
  }
  
  static var clickOutsideClosesTranslationWindow: Bool {
    get {
      UserDefaults.standard.bool(forKey: self.clickOutsideTranslationWindowKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: self.clickOutsideTranslationWindowKey)
    }
  }
  
  static func setupDefaults() {
    guard
      let url = Bundle.main.url(forResource: "Defaults", withExtension: "plist"),
      let data = try? Data(contentsOf: url),
      let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
    else { return }
    UserDefaults.standard.register(defaults: dict)
  }
  
  // MARK: - Private
  
  private let sourceLanguageKey = "com.yuriik.BetterTranslate.SourceLanguage"
  private let targetLanguageKey = "com.yuriik.BetterTranslate.TargetLanguage"
  private static let escClosesTranslationWindowKey = "com.yuriik.BetterTranslate.escClosesTranslationWindow"
  private static let clickOutsideTranslationWindowKey = "com.yuriik.BetterTranslate.clickOutsideTranslationWindow"
  
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
