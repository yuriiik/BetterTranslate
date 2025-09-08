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
    VStack {
      Toggle("Launch at login", isOn: Binding(
        get: { self.viewModel.isLaunchAtLoginEnabled },
        set: { self.viewModel.setLaunchAtLoginEnabled($0) }))
      HStack {
        if self.viewModel.isLaunchAtLoginRequiresApproval {
          Text("Pending approval in System Settings.")
          Button("Open System Settings") {
            self.viewModel.openLoginItemsSettings()
          }
          .buttonStyle(.link)
        }
      }
    }
    .frame(width: 400, height: 400)
  }
}

#Preview {
  SettingsView()
}
