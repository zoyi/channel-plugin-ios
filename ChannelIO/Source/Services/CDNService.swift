//
//  CDNService.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/04.
//

import Alamofire

enum CDNService: URLConvertible {
  case UploadFile(String, String)

  typealias ParametersType = Parameters

  static let queue = DispatchQueue(label: "com.zoyi.channel.cdn", qos: .background, attributes: .concurrent)

  var baseURL: String {
    return CHUtils.getCurrentStage().cdnEndPoint
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
      headers["Accept-language"] = locale.rawValue
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
