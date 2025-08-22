//
//  TranslateService.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 21.08.2025.
//

protocol TranslateService {
  func translateText(_ text: String, from sourceLang: String, to targetLang: String, completion: @escaping (_ translation: String?) -> Void)
}
