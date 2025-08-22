//
//  GoogleTranslateService.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 21.08.2025.
//

import Foundation

final class GoogleTranslateService: TranslateService {
  
  // MARK: - TranslateService
  
  func translateText(_ text: String, from sourceLang: String, to targetLang: String, completion: @escaping (_ translation: String?) -> Void) {
    // Ensure the text is URL-encoded
    guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      print("Failed to encode text for translation")
      completion(nil)
      return
    }
    
    // Build the Google Translate API URL
    let apiUrl = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLang)&tl=\(targetLang)&dt=t&dj=1&q=\(encodedText)"
    
    guard let url = URL(string: apiUrl) else {
      print("Invalid URL for translation API")
      completion(nil)
      return
    }
    
    // Create the data task
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        print("Translation API error: \(error)")
        completion(nil)
        return
      }
      
      guard let data = data else {
        print("No data received from translation API")
        completion(nil)
        return
      }
      
      // Parse the response as JSON
      if let translationResult = try? JSONDecoder().decode(TranslationResult.self, from: data) {
        var translatedText = ""
        translationResult.sentences
          .compactMap { $0.trans }
          .forEach { translatedText += $0 }
        completion(translatedText)
      } else {
        print("Unexpected response format from translation API")
        completion(nil)
      }
    }
    
    // Start the data task
    task.resume()
  }
}

private struct TranslationResult: Decodable {
  struct Sentence: Decodable {
    let trans: String?
    let orig: String?
  }
  let sentences: [Sentence]
}
