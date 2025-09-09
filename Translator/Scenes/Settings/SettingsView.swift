//
//  SettingsView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 06.09.2025.
//

import SwiftUI

struct SettingsView: View {  
  @StateObject private var viewModel = SettingsViewModel()
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Welcome to Better Translate!")
      Text("Select any text and press 􀆔-C-C to translate it.")
        .bold()
      Divider()
      Toggle("Launch at login", isOn: Binding(
        get: { self.viewModel.isLaunchAtLoginEnabled },
        set: { self.viewModel.setLaunchAtLoginEnabled($0) }))
        if self.viewModel.isLaunchAtLoginRequiresApproval {
          HStack {
            Text("Pending approval in System Settings.")
            Button("Open System Settings") {
              self.viewModel.openLoginItemsSettings()
            }
            .buttonStyle(.link)
          }
        }
    }
    .padding(16)
  }
}

#Preview {
  SettingsView()
}
