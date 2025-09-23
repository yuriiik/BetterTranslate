//
//  SettingsView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import SwiftUI

struct SettingsView: View {
  @StateObject private var viewModel = SettingsViewModel()
  
  @State private var translationWebsite: String = ""
  
  private func saveTranslationWebsite() {
    self.translationWebsite = self.translationWebsite.trimmingCharacters(in: .whitespacesAndNewlines)
    self.viewModel.translationWebsite = self.translationWebsite
  }
  
  var body: some View {
    Form {
      Text("Welcome to Better Translate!")
      Text("Select any text and press 􀆔-C-C to translate it.")
        .bold()
      Divider()
      LabeledContent("Startup:") {
        Toggle("Launch at login", isOn: Binding(
          get: { self.viewModel.isLaunchAtLoginEnabled },
          set: { self.viewModel.setLaunchAtLoginEnabled($0) }))
      }
      if self.viewModel.isLaunchAtLoginRequiresApproval {
        HStack {
          Text("⚠️ Pending approval in System Settings:")
          Button("Open") {
            self.viewModel.openLoginItemsSettings()
          }
        }
        .controlSize(.small)
      }
      Toggle("Show this window when starting Better Translate", isOn: Binding(
        get: { self.viewModel.openSettingsOnAppLaunch },
        set: { self.viewModel.openSettingsOnAppLaunch = $0 }))
      Divider()
      LabeledContent("Controls:") {
        Toggle("Esc closes translation window", isOn: Binding(
          get: { self.viewModel.escClosesTranslationWindow },
          set: { self.viewModel.escClosesTranslationWindow = $0 }))
      }
      Toggle("Click outside closes translation window", isOn: Binding(
        get: { self.viewModel.clickOutsideClosesTranslationWindow },
        set: { self.viewModel.clickOutsideClosesTranslationWindow = $0 }))
      Divider()
      TextField("Translation Website:", text: self.$translationWebsite, prompt: Text("Translation website address"))
        .onAppear {
          self.translationWebsite = self.viewModel.translationWebsite
        }
        .onDisappear {
          self.saveTranslationWebsite()
        }
        .onSubmit {
          self.saveTranslationWebsite()
        }
    }
    .padding(16)
  }
}

#Preview {
  SettingsView()
}
