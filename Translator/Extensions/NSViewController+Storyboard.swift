//
//  NSViewController+Storyboard.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 30.08.2025.
//

import AppKit

extension NSViewController {
  class func fromStoryboard(named storyboardName: String? = nil) -> Self? {
    let storyboardName = storyboardName ?? String(describing: self)
      .replacingOccurrences(
        of: "ViewController",
        with: "",
        options: .caseInsensitive,
        range: nil)
    let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
    return storyboard.instantiateInitialController() as? Self
  }
}
