//
//  SettingsViewModel.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import AppKit
import ServiceManagement

class SettingsViewModel: ObservableObject {
  
  // MARK: - Initialization
  
  init() {
    self.updateLaunchAtLoginFlag()
    self.updateTranslationWebsiteAddress()
    self.updateTranslationWebsite()
    self.startMonitoringAppState()
  }
  
  deinit {
    self.stopMonitoringAppState()
  }

  // MARK: - Public
  
  @Published private(set) var isLaunchAtLoginEnabled: Bool = false
  
  var escClosesTranslationWindow: Bool {
    get { AppSettings.shared.escClosesTranslationWindow }
    set {
      AppSettings.shared.escClosesTranslationWindow = newValue
      self.objectWillChange.send()
    }
  }
  
  var openSettingsOnAppLaunch: Bool {
    get { AppSettings.shared.openSettingsOnAppLaunch }
    set {
      AppSettings.shared.openSettingsOnAppLaunch = newValue
      self.objectWillChange.send()
    }
  }
  
  var clickOutsideClosesTranslationWindow: Bool {
    get { AppSettings.shared.clickOutsideClosesTranslationWindow }
    set {
      AppSettings.shared.clickOutsideClosesTranslationWindow = newValue
      self.objectWillChange.send()
    }
  }
  
  lazy var translationWebsites: [TranslationWebsite] = {
    return AppSettings.shared.translationWebsites
      .map { .init(name: $0.key, address: $0.value) }
      .sorted { $0.name < $1.name }
  }()
  
  @Published var translationWebsite: TranslationWebsite?
  
  func selectTranslationWebsite(_ translationWebsite: TranslationWebsite?) {
    if let translationWebsite {
      self.translationWebsite = translationWebsite
      self.translationWebsiteAddress = translationWebsite.address
      self.saveTranslationWebsiteAddress()
    }
  }
  
  @Published var translationWebsiteAddress: String = "" {
    didSet {
      self.updateTranslationWebsite()
    }
  }
  
  func saveTranslationWebsiteAddress() {
    self.translationWebsiteAddress = self.translationWebsiteAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    AppSettings.shared.setTranslationWebsite(self.translationWebsiteAddress)
  }
  
  var isLaunchAtLoginRequiresApproval: Bool {
    return SMAppService.mainApp.status == .requiresApproval
  }
  
  func setLaunchAtLoginEnabled(_ enabled: Bool) {
    defer {
      self.updateLaunchAtLoginFlag()
    }
    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      // handle error
    }
  }
  
  func openLoginItemsSettings() {
    SMAppService.openSystemSettingsLoginItems()
  }
  
  // MARK: - Private
  
  private var activationObserver: NSObjectProtocol?
  
  private func startMonitoringAppState() {
    self.activationObserver =  NotificationCenter.default.addObserver(
      forName: NSApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main) { [weak self] _ in
        self?.updateLaunchAtLoginFlag()
      }
  }
  
  private func stopMonitoringAppState() {
    if let observer = self.activationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  private func updateLaunchAtLoginFlag() {
    let isLaunchAtLoginEnabled = SMAppService.mainApp.status == .enabled
    if self.isLaunchAtLoginEnabled != isLaunchAtLoginEnabled {
      self.isLaunchAtLoginEnabled = isLaunchAtLoginEnabled
    }
  }
  
  private func updateTranslationWebsiteAddress() {
    self.translationWebsiteAddress = AppSettings.shared.translationWebsite ?? ""
  }
  
  private func updateTranslationWebsite() {
    self.translationWebsite = self.translationWebsites.first {
      $0.address == self.translationWebsiteAddress
    }
  }
}

struct TranslationWebsite: Hashable, Identifiable {
  let name: String
  let address: String
  
  var id: String {
    self.address
  }
}
