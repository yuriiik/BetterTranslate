//
//  SettingsView.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import SwiftUI

struct SettingsView: View {
  @StateObject private var viewModel = SettingsViewModel()
  
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
      Picker("Translation Website:", selection: Binding(
        get: { self.viewModel.translationWebsite },
        set: { self.viewModel.selectTranslationWebsite($0) })) {
          if self.viewModel.translationWebsite == nil {
            Text("Custom")
              .tag(nil as TranslationWebsite?)
          }
          ForEach(self.viewModel.translationWebsites) { website in
            Text(website.name)
              .tag(Optional(website))
          }
        }
      TextField(String(), text: self.$viewModel.translationWebsiteAddress, prompt: Text("Translation website address"))
        .onDisappear {
          self.viewModel.saveTranslationWebsiteAddress()
        }
        .onSubmit {
          self.viewModel.saveTranslationWebsiteAddress()
        }
      Picker("Dark Mode:", selection: self.$viewModel.darkMode) {
          ForEach(self.viewModel.darkModeOptions) { darkMode in
            Text(darkMode.description)
              .tag(darkMode)
          }
        }
    }
    .padding(16)
  }
}

#Preview {
  SettingsView()
}
