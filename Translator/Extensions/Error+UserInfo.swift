//
//  Error+UserInfo.swift
//  Translator
//
//  Created by Yurii Kupratsevych on 20.09.2025.
//

import Foundation

extension Error {
  var failingURLString: String? {
    let url = (self as NSError).userInfo[NSURLErrorFailingURLErrorKey] as? NSURL
    return url?.absoluteString
  }
}
