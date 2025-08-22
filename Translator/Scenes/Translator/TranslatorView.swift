//
//  TranslatorView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 19.08.2025.
//

import SwiftUI

struct TranslatorView: View {
  @ObservedObject var viewModel = TranslatorViewModel()

  var body: some View {
    VStack(spacing: 16) {
      ScrollView {
        Text(self.viewModel.originalText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(NSColor.windowBackgroundColor))
          .cornerRadius(8)
      }
      .frame(height: 300)

      Divider()

      ScrollView {
        Text(self.viewModel.translatedText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(NSColor.controlBackgroundColor))
          .cornerRadius(8)
      }
      .frame(height: 300)
    }
    .padding(20)
    .frame(minWidth: 500)
  }
}
