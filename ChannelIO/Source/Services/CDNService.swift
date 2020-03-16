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
    var headers: [HTTPHeader] = []

    if let jwt = PrefStore.getSessionJWT() {
      headers.append(HTTPHeader(name: "x-session", value: jwt))
    }

    if let locale = CHUtils.getLocale() {
      headers.append(HTTPHeader(name: "Accept-language", value: locale.rawValue))
    }

    headers.append(HTTPHeader(name: "Accept", value: "application/json"))
    headers.append(HTTPHeader(name: "User-Agent", value: CHUtils.generateUserAgent()))
    return HTTPHeaders(headers)
  }

  func asURL() throws -> URL {
    let url = try self.baseURL.asURL()
    return url.appendingPathComponent(self.path)
  }
}
