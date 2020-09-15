//
//  NSError.swift
//  CHPlugin
//
//  Created by Haeun Chung on 31/10/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHError: Mappable {
  var message: String = ""
  var field: String?

  init?(map: Map) {
    // initialize CHError
  }

  mutating func mapping(map: Map) {
    message <- map["message"]
    field <- map["field"]
  }
}

enum ChannelError: Error {
  case entityError
  case networkError
  case parseError
  case serverError(msg: String)
  case unknownError(msg: String = "Unknown error")
  case notFoundError
  case parameterError
  case pathError
  case sendFileError
  case serviceBlockedError
  case versionError

  init(msg: String) {
    self = .serverError(msg: msg)
  }

  init(data: Data? = nil, error: Error) {
    if let error = CHUtils.getServerErrorMessage(data: data)?.first {
      self = .serverError(msg: error)
    } else {
      self = .unknownError(msg: error.localizedDescription)
    }
  }
}

extension ChannelError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .entityError: return "Entity error"
    case .networkError: return "Network error"
    case .parseError: return "Parse error"
    case .unknownError(let msg): return "\(msg)"
    case .serverError(let msg): return "\(msg)"
    case .notFoundError: return "Not found"
    case .parameterError: return "Parameter invalid"
    case .pathError: return "path error"
    case .sendFileError: return "send file error"
    case .serviceBlockedError: return "service block error"
    case .versionError: return "sdk version error"
    }
  }
}
