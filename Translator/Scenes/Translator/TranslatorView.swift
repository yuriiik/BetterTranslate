//
//  TranslatorView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 19.08.2025.
//

import SwiftUI
import Translation

struct TranslatorView: View {
  @ObservedObject var viewModel = TranslatorViewModel()
  @State private var configuration: TranslationSession.Configuration?

  var body: some View {
    VStack(spacing: 16) {
      ScrollView {
        Text(self.viewModel.sourceText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(NSColor.windowBackgroundColor))
          .cornerRadius(8)
      }
      .frame(height: 300)

      Divider()
      
      HStack {
        Picker("From", selection: self.$viewModel.sourceLanguage) {
          if self.viewModel.sourceLanguage == nil {
            Text("Choose language").tag(nil as Locale.Language?)
          }
          ForEach(self.viewModel.availableLanguages) { language in
            Text(language.localizedName)
              .tag(Optional(language.localeLanguage))
          }
        }
        Picker("To", selection: self.$viewModel.targetLanguage) {
          if self.viewModel.targetLanguage == nil {
            Text("Choose language").tag(nil as Locale.Language?)
          }
          ForEach(self.viewModel.availableLanguages) { language in
            Text(language.localizedName)
              .tag(Optional(language.localeLanguage))
          }
        }
        Button("Reset") {
          self.viewModel.resetSelectedLanguages()
        }
      }
      
      Divider()

      ScrollView {
        Text(self.viewModel.targetText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(NSColor.controlBackgroundColor))
          .cornerRadius(8)
      }
      .frame(height: 300)
    }
    .onChange(of: self.viewModel.sourceLanguage) {
      self.updateTranslation()
    }
    .onChange(of: self.viewModel.targetLanguage) {
      self.updateTranslation()
    }
    .onChange(of: self.viewModel.sourceText, initial: true) {
      self.updateTranslation()
    }
    .translationTask(self.configuration) { session in
      do {
        let response = try await session.translate(self.viewModel.sourceText)
        self.viewModel.targetText = response.targetText
      } catch {
        // handle error
      }
    }
    .padding(20)
    .frame(minWidth: 500)
  }
  
  private func updateTranslation() {
    guard
      let selectedFrom = self.viewModel.sourceLanguage,
      let selectedTo = self.viewModel.targetLanguage
    else { return }
    
    if self.configuration != nil {
      if self.configuration?.source != selectedFrom {
        self.configuration?.source = selectedFrom
      } else if self.configuration?.target != selectedTo {
        self.configuration?.target = selectedTo
      } else {
        self.configuration?.invalidate()
      }
    } else {
      self.configuration = .init(
        source: selectedFrom,
        target: selectedTo)
    }
  }
}
