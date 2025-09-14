//
//  AppSettings.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 23.08.2025.
//

import Foundation

class AppSettings {
  
  // MARK: - Initialization
  
  init() {
    self.setupDefaults()
    self.translationWebsite = UserDefaults.standard.string(forKey: Keys.translationWebsite)
  }
  
  // MARK: - Public
  
  static let shared = AppSettings()
  
  var sourceLanguage: Locale.Language? {
    get { self.getLanguage(for: Keys.sourceLanguage) }
    set { self.setLanguage(newValue, for: Keys.sourceLanguage) }
  }
  
  var targetLanguage: Locale.Language? {
    get { self.getLanguage(for: Keys.targetLanguage) }
    set { self.setLanguage(newValue, for: Keys.targetLanguage) }
  }
  
  var escClosesTranslationWindow: Bool {
    get { UserDefaults.standard.bool(forKey: Keys.escClosesTranslationWindow) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.escClosesTranslationWindow) }
  }
  
  var clickOutsideClosesTranslationWindow: Bool {
    get { UserDefaults.standard.bool(forKey: Keys.clickOutsideClosesTranslationWindow) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.clickOutsideClosesTranslationWindow) }
  }
  
  @Published private(set) var translationWebsite: String?
  
  func setTranslationWebsite(_ translationWebsite: String?) {
    UserDefaults.standard.set(translationWebsite, forKey: Keys.translationWebsite)
    self.translationWebsite = translationWebsite
  }
  
  // MARK: - Private
  
  private struct Keys {
    static let sourceLanguage = "com.yuriik.BetterTranslate.SourceLanguage"
    static let targetLanguage = "com.yuriik.BetterTranslate.TargetLanguage"
    static let escClosesTranslationWindow = "com.yuriik.BetterTranslate.escClosesTranslationWindow"
    static let clickOutsideClosesTranslationWindow = "com.yuriik.BetterTranslate.clickOutsideClosesTranslationWindow"
    static let translationWebsite = "com.yuriik.BetterTranslate.translationWebsite"
  }
  
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
  
  private func setupDefaults() {
    guard
      let url = Bundle.main.url(forResource: "Defaults", withExtension: "plist"),
      let data = try? Data(contentsOf: url),
      let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
    else { return }
    UserDefaults.standard.register(defaults: dict)
  }
}
