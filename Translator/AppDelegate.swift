//
//  AppDelegate.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 18.08.2025.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
  
  // MARK: - NSApplicationDelegate

  func applicationDidFinishLaunching(_ notification: Notification) {
    self.translationManager.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    self.translationManager.stop()
  }
  
  // MARK: - Private
  
  private let translationManager = TranslationManager()
}
