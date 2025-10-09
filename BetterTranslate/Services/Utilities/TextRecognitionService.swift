//
//  TextRecognitionService.swift
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 09.10.2025.
//

import AppKit
import Vision

class TextRecognitionService {
  
  // MARK: - Public
  
  func getTextFromImage(_ image: CGImage, _ completion: @escaping (Result<String, Error>) -> Void) {
    let request = VNRecognizeTextRequest { (request, error) in
      if let error {
        completion(.failure(error))
        return
      }
      var recognizedText = ""
      if let results = request.results as? [VNRecognizedTextObservation] {
        for observation in results {
          if let topCandidate = observation.topCandidates(1).first {
            recognizedText += topCandidate.string + " "
          }
        }
        recognizedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      completion(.success(recognizedText))
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    let requestHandler = VNImageRequestHandler(cgImage: image)
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try requestHandler.perform([request])
      } catch {
        completion(.failure(error))
      }
    }
  }
}
