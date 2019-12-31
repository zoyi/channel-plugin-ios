//
//  CDNService.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/04.
//

import Alamofire

enum CDNEndPointType: String {
  case production = "https://media.channel.io"
  case exp = "http://media.exp.channel.io"
  case stage = "http://media.staging.channel.io"
}

enum CDNService: URLConvertible {
  case UploadFile(String, String)

  typealias ParametersType = Parameters

  static let queue = DispatchQueue(label: "com.zoyi.channel.cdn", qos: .background, attributes: .concurrent)

  var baseURL: String {
    var url = CDNEndPointType.production.rawValue
    switch CHUtils.getCurrentStage() {
    case .development:
      url = CDNEndPointType.exp.rawValue
    case .staging:
      url = CDNEndPointType.stage.rawValue
    case .production:
      url = CDNEndPointType.production.rawValue
    }
    return url
  }

  var method: HTTPMethod {
    switch self {
    case .UploadFile:
      return .post
    }
  }

  var path: String {
    switch self {
    case .UploadFile(let channelId, let fileName):
      return "/file/\(channelId)/message/\(fileName)"
    }
  }

  var authHeaders: HTTPHeaders {
    var headers: [String: String] = [:]

    if let jwt = PrefStore.getSessionJWT() {
      headers["x-session"] = jwt
    }

    if let locale = CHUtils.getLocale() {
      headers["X-language"] = locale.rawValue
    }

    headers["Accept"] = "application/json"
    headers["User-Agent"] = CHUtils.generateUserAgent()
    return headers
  }

  func asURL() throws -> URL {
    let url = try self.baseURL.asURL()
    return url.appendingPathComponent(self.path)
  }
}
