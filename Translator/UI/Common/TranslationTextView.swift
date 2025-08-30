//
//  TranslationTextView.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 25.08.2025.
//

import SwiftUI

struct TranslationTextView: View {
  private var text: String
  @State private var textHeight = CGFloat.zero
  private let maxHeight = 200.0
  
  init(text: String) {
    self.text = text
  }
  
  var body: some View {
    ScrollView {
      Text(self.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .background(
          GeometryReader { geometry in
            Color.clear
              .onAppear {
                self.textHeight = geometry.size.height
              }
              .onChange(of: geometry.size.height) { oldValue, newValue in
                self.textHeight = newValue
              }
          }
        )
    }
    .frame(height: min(self.textHeight, self.maxHeight))
  }
}
