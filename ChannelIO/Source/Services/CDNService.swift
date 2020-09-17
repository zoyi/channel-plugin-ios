//
//  CDNService.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/04.
//

enum CDNService: AF_URLConvertible {
  case UploadFile(String, String)

  typealias ParametersType = AF_Parameters

  static let queue = DispatchQueue(label: "com.zoyi.channel.cdn", qos: .background, attributes: .concurrent)

  var baseURL: String {
    return CHUtils.getCurrentStage().cdnEndPoint
  }

  var method: AF_HTTPMethod {
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

  var authHeaders: AF_HTTPHeaders {
    var headers: [AF_HTTPHeader] = []

    if let jwt = PrefStore.getSessionJWT() {
      headers.append(AF_HTTPHeader(name: "x-session", value: jwt))
    }

    if let locale = CHUtils.getLocale() {
      headers.append(AF_HTTPHeader(name: "Accept-language", value: locale.rawValue))
    }

    headers.append(AF_HTTPHeader(name: "Accept", value: "application/json"))
    headers.append(AF_HTTPHeader(name: "User-Agent", value: CHUtils.generateUserAgent()))
    return AF_HTTPHeaders(headers)
  }

  func asURL() throws -> URL {
    let url = try self.baseURL.asURL()
    return url.appendingPathComponent(self.path)
  }
}
