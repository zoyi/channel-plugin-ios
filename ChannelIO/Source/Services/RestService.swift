//
//  RestService.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire

enum EPType: String {
  case PRODUCTION = "https://api.channel.io"
  case ALPHA = "http://api.exp.channel.io"
  case BETA = "http://api.staging.channel.io"
}

enum RestRouter: URLRequestConvertible {
  case Boot(String, ParametersType)
  case CreateUserChat(String)
  case CloseUserChat(String, ParametersType)
  case CreateMessage(String, ParametersType)
  case CheckVersion
  case CreateSupportBotChat(String)
  case CheckNudgeReach(String)
  case CreateNudgeChat(String)
  case GetNudges(String)
  case GetPlugin(String)
  case GetGeoIP
  case GetChannel
  case GetCountryCodes
  case GetOperators
  case GetExternalMessengers
  case GetSupportBot(String)
  case GetSupportBotEntry(String)
  case GetUserChats(ParametersType)
  case GetUserChat(String)
  case GetMessages(String, ParametersType)
  case GetProfileBotSchemas(String)
  case KeepNudge(String)
  case ReplySupportBot(String, String, ParametersType)
  case RegisterToken(ParametersType)
  case RemoveUserChat(String)
  case ReviewUserChat(String, ParametersType)
  case SendEvent(String, ParametersType)
  case SetMessagesRead(String)
  case SendPushAck(String)
  case TouchGuest
  case Translate(String, ParametersType)
  case UpdateGuest(ParametersType)
  case UpdateProfileItem(String, ParametersType)
  case UnregisterToken(String, ParametersType)
  case UploadFile(String, ParametersType)

  var baseURL: String {
    get {
      var url = EPType.PRODUCTION.rawValue
      switch CHUtils.getCurrentStage() {
      case .development:
        url = EPType.ALPHA.rawValue
      case .staging:
        url = EPType.BETA.rawValue
      case .production:
        url = EPType.PRODUCTION.rawValue
      }
      return url
    }
  }

  typealias ParametersType = Parameters
  static let queue = DispatchQueue(label: "com.zoyi.channel.restapi", qos: .background, attributes: .concurrent)
  static let packageName = "com.zoyi.channel.plugin.ios"
  
  var method: HTTPMethod {
    switch self {
    case .CreateMessage,
         .CreateUserChat, .UploadFile, .RegisterToken,
         .SendEvent, .Boot,
         .UpdateProfileItem, .TouchGuest,
         .CreateSupportBotChat, .ReplySupportBot,
         .CheckNudgeReach,
         .CreateNudgeChat,
         .KeepNudge:
      return .post
    case .GetMessages, .GetUserChat,
         .GetUserChats, .CheckVersion, .GetGeoIP,
         .GetCountryCodes,
         .GetOperators,
         .GetPlugin, .Translate,
         .GetSupportBot, .GetSupportBotEntry,
         .GetNudges,
         .GetExternalMessengers,
         .GetProfileBotSchemas,
         .GetChannel:
      return .get
    case .SetMessagesRead,
         .RemoveUserChat,
         .CloseUserChat,
         .ReviewUserChat,
         .SendPushAck,
         .UpdateGuest:
      return .put
    case .UnregisterToken:
      return .delete
    }
  }
  
  // MARK: Paths
  var path: String {
    switch self {
    case .Boot(let pluginKey, _):
      return "/app/plugins/\(pluginKey)/boot/v2"
    case .CheckNudgeReach(let nudgeId):
      return "/app/nudges/\(nudgeId)/reach"
    case .CreateNudgeChat(let nudgeId):
      return "/app/nudges/\(nudgeId)/user_chats"
    case .CreateUserChat(let pluginId):
      return "/app/plugins/\(pluginId)/user_chats"
    case .CreateSupportBotChat(let supportBotId):
      return "/app/support_bots/\(supportBotId)/user_chats"
    case .CreateMessage(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages"
    case .CheckVersion:
      return "/packages/com.zoyi.channel.plugin.ios/versions/latest"
    case .CloseUserChat(let userChatId, _):
      return "/app/user_chats/\(userChatId)/close"
    case .GetMessages(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages"
    case .GetCountryCodes:
      return "/available/countries"
    case .GetChannel:
      return "/app/channels"
    case .GetExternalMessengers:
      return "/app/channels/messengers"
    case .GetOperators:
      return "/app/channels/operators"
    case .GetPlugin(let pluginId):
      return "/app/plugins/\(pluginId)"
    case .GetUserChats:
      return "/app/user_chats"
    case .GetGeoIP:
      return "/geoip"
    case .GetUserChat(let userChatId):
      return "/app/user_chats/\(userChatId)"
    case .GetSupportBot(let pluginId):
      return "/app/plugins/\(pluginId)/support_bot"
    case .GetSupportBotEntry(let supportBotId):
      return "/app/support_bots/\(supportBotId)/entry"
    case .GetNudges(let pluginId):
      return "/app/plugins/\(pluginId)/nudges"
    case .GetProfileBotSchemas(let pluginId):
      return "/app/plugins/\(pluginId)/profile_bot_schemas"
    case .KeepNudge(let userChatId):
      return "/app/user_chats/\(userChatId)/nudge/keep"
    case .RemoveUserChat(let userChatId):
      return "/app/user_chats/\(userChatId)/remove"
    case .ReviewUserChat(let userChatId, _):
      return "/app/user_chats/\(userChatId)/review"
    case .RegisterToken:
      return "/app/device_tokens"
    case .ReplySupportBot(let userChatId, let buttonId, _):
      return "/app/user_chats/\(userChatId)/support_bot/buttons/\(buttonId)"
    case .SetMessagesRead(let userChatId):
      return "/app/user_chats/\(userChatId)/messages/read"
    case .SendPushAck(let userChatId):
      return "/app/user_chats/\(userChatId)/messages/receive"
    case .SendEvent(let pluginId, _):
      return "/app/plugins/\(pluginId)/events/v2"
    case .Translate(let messageId, _):
      return "/app/messages/\(messageId)/translate"
    case .TouchGuest:
      return "/app/guests/touch"
    case .UpdateProfileItem(let messageId, _):
      return "/app/messages/\(messageId)/profile_bot"
    case .UploadFile(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages/file"
    case .UpdateGuest(_):
      return "/app/guests"
    case .UnregisterToken(let key, _):
      return "/app/device_tokens/ios/\(key)"
    }
  }
  
  func addAuthHeaders(request: URLRequest) -> URLRequest {
    var req = request
    var headers = req.allHTTPHeaderFields ?? [String: String]()
    
    if let key = PrefStore.getCurrentGuestKey() {
      headers["X-Guest-Jwt"] = key
    }
    
    if let locale = CHUtils.getLocale() {
      headers["X-Locale"] = locale.rawValue
    }
    
    headers["Accept"] = "application/json"
    headers["User-Agent"] = CHUtils.generateUserAgent()
    
    let now = Date()
    let cookies = HTTPCookieStorage.shared.cookies?
      .filter({ (cookie) -> Bool in
        guard cookie.domain.hasSuffix("channel.io") else { return false }
        if let expDate = cookie.expiresDate, expDate > now {
          return true
        }  else {
          HTTPCookieStorage.shared.deleteCookie(cookie)
          return false
        }
    }) ?? []
    
    req.allHTTPHeaderFields = headers.merging(HTTPCookie.requestHeaderFields(with: cookies)) { $1 }
    return req
  }
  
  // MARK: Encoding
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
    var request = urlRequest
    
    if let body = parameters?["body"] as? ParametersType {
      request = try JSONEncoding.default.encode(urlRequest, with: body)
    }
    
    if let url = parameters?["url"] as? ParametersType {
      request = try URLEncoding.default.encode(request, with: url)
    }
    
    if let query = parameters?["query"] as? ParametersType {
      request = try CustomQueryEncoding().encode(request, with: query)
    }
    
    if let paths = parameters?["paths"] as? [String] {
      for path in paths {
        request = request.urlRequest?.url?.absoluteString.appending(path) as! URLRequestConvertible
      }
    }
    
    if let headers = parameters?["headers"] as? ParametersType, var req = try? request.asURLRequest() {
      for (key, val) in headers {
        if let value = val as? String, value != "" {
          req.setValue(value, forHTTPHeaderField: key)
        }
      }
      request = req
    }
    
    return request as! URLRequest
  }
  
  // MARK: URLRequestConvertible
  func asURLRequest() throws -> URLRequest {
    let url = try self.baseURL.asURL()
    
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.timeoutInterval = 5
    
    switch self {
    case .Boot(_, let params),
         .GetMessages(_, let params),
         .CreateMessage(_, let params),
         .UploadFile(_, let params),
         .GetUserChats(let params),
         .RegisterToken(let params),
         .SendEvent(_, let params),
         .UpdateProfileItem(_, let params),
         .Translate(_, let params),
         .CloseUserChat(_, let params),
         .ReviewUserChat(_, let params),
         .UnregisterToken(_, let params),
         .ReplySupportBot(_, _, let params),
         .UpdateGuest(let params):
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: params)
    case .GetUserChat, .GetPlugin,
         .GetCountryCodes,
         .GetOperators,
         .CreateUserChat,
         .GetSupportBotEntry,
         .CreateSupportBotChat,
         .SendPushAck,
         .GetNudges,
         .CheckNudgeReach,
         .SetMessagesRead,
         .CreateNudgeChat,
         .GetSupportBot,
         .GetExternalMessengers,
         .GetProfileBotSchemas,
         .KeepNudge:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    default:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    }
    
    return urlRequest
  }
}
