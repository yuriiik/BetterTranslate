//
//  NSEvent+Location.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 11.09.2025.
//

import AppKit

@MainActor
extension NSEvent {
  var locationInScreenCoordinates: NSPoint {
    self.window?.convertPoint(toScreen: self.locationInWindow) ?? self.locationInWindow
  }
}
