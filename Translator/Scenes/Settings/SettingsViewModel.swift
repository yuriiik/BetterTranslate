//
//  SettingsViewModel.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import AppKit
import ServiceManagement

class SettingsViewModel: ObservableObject {
  
  // MARK: - Initialization
  
  init() {
    self.updateLaunchAtLoginFlag()
    self.startMonitoringAppState()
  }
  
  deinit {
    self.stopMonitoringAppState()
  }

  // MARK: - Public
  
  @Published private(set) var isLaunchAtLoginEnabled: Bool = false
  
  var escClosesTranslationWindow: Bool {
    get {
      AppSettings.escClosesTranslationWindow
    }
    set {
      AppSettings.escClosesTranslationWindow = newValue
      self.objectWillChange.send()
    }
  }
  
  var clickOutsideClosesTranslationWindow: Bool {
    get {
      AppSettings.clickOutsideClosesTranslationWindow
    }
    set {
      AppSettings.clickOutsideClosesTranslationWindow = newValue
      self.objectWillChange.send()
    }
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
}
