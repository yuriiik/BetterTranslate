//
//  AppDelegate.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 18.08.2025.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ notification: Notification) {
    self.appManager.startMonitoringPasteboard()
  }

  func applicationWillTerminate(_ notification: Notification) {
    self.appManager.stopMonitoringPasteboard()
  }
  
  // MARK: - Private
  
  private lazy var appManager = AppManager()
}
