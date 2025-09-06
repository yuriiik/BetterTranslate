//
//  TranslationTextEditorView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 04.09.2025.
//

import SwiftUI

struct TranslationTextEditorView: View {
  @Binding var text: String
  @State private var textHeight = CGFloat.zero
  private let minHeight = 30.0
  private let maxHeight = 200.0
    
  var body: some View {
    TextEditor(text: self.$text)
      .frame(minHeight: self.minHeight, maxHeight: self.maxHeight)
      .fixedSize(horizontal: false, vertical: true)
      .padding()
      .scrollContentBackground(.hidden)
      .background(Color(NSColor.windowBackgroundColor))
      .font(.body)
      .cornerRadius(8)
  }
}
