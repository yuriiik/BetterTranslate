//
//  TranslatorViewModel.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.08.2025.
//

import Foundation

class TranslatorViewModel: ObservableObject {
  @Published var originalText = ""
  @Published var translatedText = ""
}
