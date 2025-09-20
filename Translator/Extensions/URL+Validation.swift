//
//  URL+Validation.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 19.09.2025.
//

import Foundation

extension URL {
  var isValidWebsite: Bool {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
      let scheme = components.scheme,
      let host = components.host
    else { return false }
    
    let allowedSchemes = ["http", "https"]
    guard allowedSchemes.contains(scheme.lowercased()) else {
      return false
    }
    
    guard host.contains(".") else {
      return false
    }
    
    return true
  }
}
