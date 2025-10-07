//
//  ScreenCapture.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 07.10.2025.
//

import AppKit

struct ScreenCapture {
  
  // MARK: - Public
  
  static func getScreenImage() -> CGImage? {
    guard FileManager.default.isExecutableFile(atPath: Self.screencapturePath) else { return nil }
    
    let tempFileURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(Self.tempFileName)
    defer {
      try? FileManager.default.removeItem(at: tempFileURL)
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: Self.screencapturePath)
    process.arguments = ["-i", "-x", "-t", Self.imageFormat, tempFileURL.path]
    do {
      try process.run()
    } catch {
      return nil
    }
    process.waitUntilExit()
        
    guard
      process.terminationStatus == 0,
      FileManager.default.fileExists(atPath: tempFileURL.path),
      let imageSource = CGImageSourceCreateWithURL(tempFileURL as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else { return nil }
    
    return image
  }
  
  // MARK: - Private
  
  private static let screencapturePath = "/usr/sbin/screencapture"
  private static let imageFormat = "png"
  private static var tempFileName: String {
    "better-translate-screen-capture-\(UUID().uuidString).\(Self.imageFormat)"
  }
}
