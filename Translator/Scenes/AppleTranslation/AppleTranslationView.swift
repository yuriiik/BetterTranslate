//
//  AppleTranslationView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 19.08.2025.
//

import SwiftUI
import Translation

struct AppleTranslationView: View {
  @ObservedObject var viewModel: AppleTranslationViewModel
  @State private var configuration: TranslationSession.Configuration?

  var body: some View {
    VStack(spacing: 16) {
      TranslationTextEditorView(text: self.$viewModel.sourceText)
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
      TranslationTextView(text: self.viewModel.targetText)
      HStack {
        Spacer()
        Button("Close (Esc)") {
          self.viewModel.close()
        }
        Spacer()
          .frame(width: 16)
        Button("Close and Turn OFF") {
          self.viewModel.closeAndTurnOff()
        }
        Spacer()
      }
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
        guard !self.viewModel.sourceText.isEmpty else {
          self.viewModel.targetText = ""
          return
        }
        let response = try await session.translate(self.viewModel.sourceText)
        self.viewModel.targetText = response.targetText
      } catch {
        // handle error
      }
    }
    .padding(20)
    .frame(width: 500)
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
