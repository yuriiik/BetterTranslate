//
//  NSMenu+Item.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 04.09.2025.
//

import AppKit

extension NSMenu {
  @discardableResult
  func addItem(title: String, target: AnyObject? = nil, action selector: Selector, keyEquivalent charCode: String, keyEquivalentModifierMask: NSEvent.ModifierFlags? = nil) -> NSMenuItem {
    let menuItem = self.addItem(
      withTitle: title,
      action: selector,
      keyEquivalent: charCode)
    menuItem.target = target
    keyEquivalentModifierMask.map {
      menuItem.keyEquivalentModifierMask = $0
    }    
    return menuItem
  }
}
