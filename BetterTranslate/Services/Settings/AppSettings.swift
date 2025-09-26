//
//  AppSettings.swift
//  BetterTranslate
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
  
  var openSettingsOnAppLaunch: Bool {
    get { UserDefaults.standard.bool(forKey: Keys.openSettingsOnAppLaunch) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.openSettingsOnAppLaunch) }
  }
  
  var escClosesTranslationWindow: Bool {
    get { UserDefaults.standard.bool(forKey: Keys.escClosesTranslationWindow) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.escClosesTranslationWindow) }
  }
  
  var clickOutsideClosesTranslationWindow: Bool {
    get { UserDefaults.standard.bool(forKey: Keys.clickOutsideClosesTranslationWindow) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.clickOutsideClosesTranslationWindow) }
  }
  
  var translationWebsites: [String: String] {
    UserDefaults.standard.dictionary(forKey: Keys.translationWebsites) as? [String: String] ?? [:]
  }
  
  @Published private(set) var translationWebsite: String?
  
  func setTranslationWebsite(_ translationWebsite: String?) {
    UserDefaults.standard.set(translationWebsite, forKey: Keys.translationWebsite)
    self.translationWebsite = translationWebsite
  }
  
  var translationPageZoom: Double {
    get { UserDefaults.standard.double(forKey: Keys.translationPageZoom) }
    set { UserDefaults.standard.set(newValue, forKey: Keys.translationPageZoom) }
  }
  
  var translationWindowSize: NSSize? {
    get {
      guard
        let size =
          UserDefaults.standard.dictionary(forKey: Keys.translationWindowSize) ??
          UserDefaults.standard.dictionary(forKey: Keys.translationWindowDefaultSize),
        let width = size["width"] as? CGFloat,
        let height = size["height"] as? CGFloat
      else { return nil }
      return .init(width: width, height: height)
    }
    set {
      if let newValue {
        let size = ["width": newValue.width, "height": newValue.height]
        UserDefaults.standard.set(size, forKey: Keys.translationWindowSize)
      } else {
        self.resetTranslationWindowSize()
      }
    }
  }
  
  var translationWindowOrigin: NSPoint? {
    get {
      guard
        let origin = UserDefaults.standard.dictionary(forKey: Keys.translationWindowOrigin),
        let x = origin["x"] as? CGFloat,
        let y = origin["y"] as? CGFloat
      else { return nil }
      return .init(x: x, y: y)
    }
    set {
      if let newValue {
        let origin = ["x": newValue.x, "y": newValue.y]
        UserDefaults.standard.set(origin, forKey: Keys.translationWindowOrigin)
      } else {
        self.resetTranslationWindowOrigin()
      }
    }
  }
  
  func resetTranslationWindowSize() {
    UserDefaults.standard.removeObject(forKey: Keys.translationWindowSize)
  }
  
  func resetTranslationWindowOrigin() {
    UserDefaults.standard.removeObject(forKey: Keys.translationWindowOrigin)
  }
  
  // MARK: - Private
  
  private struct Keys {
    static let openSettingsOnAppLaunch = "com.yuriik.BetterTranslate.openSettingsOnAppLaunch"
    static let escClosesTranslationWindow = "com.yuriik.BetterTranslate.escClosesTranslationWindow"
    static let clickOutsideClosesTranslationWindow = "com.yuriik.BetterTranslate.clickOutsideClosesTranslationWindow"
    static let translationWebsites = "com.yuriik.BetterTranslate.translationWebsites"
    static let translationWebsite = "com.yuriik.BetterTranslate.translationWebsite"
    static let translationPageZoom = "com.yuriik.BetterTranslate.translationPageZoom"
    static let translationWindowDefaultSize = "com.yuriik.BetterTranslate.translationWindowDefaultSize"
    static let translationWindowSize = "com.yuriik.BetterTranslate.translationWindowSize"
    static let translationWindowOrigin = "com.yuriik.BetterTranslate.translationWindowOrigin"
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
