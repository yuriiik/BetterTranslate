//
//  ScreenCaptureService.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 07.10.2025.
//

import AppKit

class ScreenCaptureService {
  
  // MARK: - Public
  
  func getScreenImage() -> CGImage? {
    guard FileManager.default.isExecutableFile(atPath: self.screencapturePath) else { return nil }
    
    let tempFileURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(self.tempFileName)
    defer {
      try? FileManager.default.removeItem(at: tempFileURL)
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: self.screencapturePath)
    process.arguments = ["-i", "-x", "-t", self.imageFormat, tempFileURL.path]
    do {
      try process.run()
    } catch {
      return nil
    }
    process.waitUntilExit()
        
    guard
      process.terminationStatus == 0,
      FileManager.default.fileExists(atPath: tempFileURL.path),
      let data = try? Data(contentsOf: tempFileURL),
      let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
      let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else { return nil }
    
    return image
  }
  
  // MARK: - Private
  
  private let screencapturePath = "/usr/sbin/screencapture"
  private let imageFormat = "png"
  private var tempFileName: String {
    "better-translate-screen-capture-\(UUID().uuidString).\(self.imageFormat)"
  }
}
