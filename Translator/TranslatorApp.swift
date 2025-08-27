//
//  TranslatorApp.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 18.08.2025.
//

import SwiftUI

@main
struct TranslatorApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
