//
//  NSMenu+Item.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 04.09.2025.
//

import Cocoa

extension NSMenu {
  @discardableResult
  func addItem(withTitle string: String, target: AnyObject, action selector: Selector?, keyEquivalent charCode: String
  ) -> NSMenuItem {
    let menuItem = self.addItem(
      withTitle: string,
      action: selector,
      keyEquivalent: charCode)
    menuItem.target = target
    return menuItem
  }
}
