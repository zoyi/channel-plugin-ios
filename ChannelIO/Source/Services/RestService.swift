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
  case GetPlugin(String)
  case GetPluginWithKey(String)
  case GetGeoIP
  case GetChannel
  case GetCountryCodes
  case GetOperators
  case GetExternalMessengers
  case GetSupportBot(String)
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
  case TouchUser
  case Translate(String, ParametersType)
  case UpdateUser(ParametersType)
  case UpdateProfileItem(String, ParametersType)
  case UnregisterToken(String)
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
  static var channelId = ""
  
  var method: HTTPMethod {
    switch self {
    case .CreateMessage,
         .CreateUserChat, .UploadFile, .RegisterToken,
         .SendEvent, .Boot,
         .UpdateProfileItem, .TouchUser,
         .CreateSupportBotChat, .ReplySupportBot,
         .CheckNudgeReach,
         .CreateNudgeChat,
         .KeepNudge:
      return .post
    case .GetMessages, .GetUserChat,
         .GetUserChats, .CheckVersion, .GetGeoIP,
         .GetCountryCodes,
         .GetOperators,
         .GetPlugin,
         .GetPluginWithKey,
         .Translate,
         .GetSupportBot,
         .GetExternalMessengers,
         .GetProfileBotSchemas,
         .GetChannel:
      return .get
    case .SetMessagesRead,
         .RemoveUserChat,
         .CloseUserChat,
         .ReviewUserChat,
         .SendPushAck,
         .UpdateUser:
      return .put
    case .UnregisterToken:
      return .delete
    }
  }
  
  // MARK: Paths
  var path: String {
    let channelId = RestRouter.channelId
    
    switch self {
    case .Boot(let pluginKey, _):
      return "/front/plugins/\(pluginKey)/boot"
    case .CheckNudgeReach(let nudgeId):
      return "/front/channels/\(channelId)/nudges/\(nudgeId)/reach"
    case .CreateNudgeChat(let nudgeId):
      return "/front/channels/\(channelId)/nudges/\(nudgeId)/user_chats"
    case .CreateUserChat(let pluginId):
      return "/front/channels/\(channelId)/plugins/\(pluginId)/user_chats"
    case .CreateSupportBotChat(let supportBotId):
      return "/front/channels/\(channelId)/support_bots/\(supportBotId)/user_chats"
    case .CreateMessage(let userChatId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/messages"
    case .CheckVersion:
      return "/packages/com.zoyi.channel.plugin.ios/versions/latest"
    case .CloseUserChat(let userChatId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/close"
    case .GetMessages(let userChatId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/messages"
    case .GetCountryCodes:
      return "/available/countries"
    case .GetChannel:
      return "/front/channels"
    case .GetExternalMessengers:
      return "/front/channels/\(channelId)/messengers"
    case .GetOperators:
      return "/front/channels/\(channelId)/operators"
    case .GetPlugin(let pluginId):
      return "/front/channels/\(channelId)/plugins/\(pluginId)"
    case .GetPluginWithKey(let key):
      return "/front/plugins/\(key)"
    case .GetUserChats:
      return "/front/channels/\(channelId)/user_chats"
    case .GetGeoIP:
      return "/geoip"
    case .GetUserChat(let userChatId):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)"
    case .GetSupportBot(let pluginId):
      return "/front/channels/\(channelId)/plugins/\(pluginId)/support_bot"
    case .GetProfileBotSchemas(let pluginId):
      return "/front/channels/\(channelId)/plugins/\(pluginId)/profile_bot_schemas"
    case .KeepNudge(let userChatId):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/nudge/keep"
    case .RemoveUserChat(let userChatId):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/trash"
    case .ReviewUserChat(let userChatId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/review"
    case .RegisterToken:
      return "/front/channels/\(channelId)/push_tokens"
    case .ReplySupportBot(let userChatId, let buttonId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/support_bot/buttons/\(buttonId)"
    case .SetMessagesRead(let userChatId):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/messages/read"
    case .SendPushAck(let userChatId):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/messages/receive"
    case .SendEvent(let pluginId, _):
      return "/front/plugins/\(pluginId)/events"
    case .Translate(let messageId, _):
      return "/front/channels/\(channelId)/messages/\(messageId)/translate"
    case .TouchUser:
      return "/front/channels/\(channelId)/users/touch"
    case .UpdateProfileItem(let messageId, _):
      return "/front/channels/\(channelId)/messages/\(messageId)/profile_bot"
    case .UploadFile(let userChatId, _):
      return "/front/channels/\(channelId)/user_chats/\(userChatId)/messages/file"
    case .UpdateUser(_):
      return "/front/channels/\(channelId)/users"
    case .UnregisterToken(let key):
      return "/front/channels/\(channelId)/push_tokens/\(key)"
    }
  }
  
  func addAuthForSimple(request: URLRequest) -> URLRequest {
    var req = request
    var headers = req.allHTTPHeaderFields ?? [String: String]()
    
    headers["Accept"] = "application/json"
    headers["User-Agent"] = CHUtils.generateUserAgent()
    req.allHTTPHeaderFields = headers
    return req
  }
  
  func addAuthHeaders(request: URLRequest) -> URLRequest {
    var req = request
    var headers = req.allHTTPHeaderFields ?? [String: String]()
    
    if let jwt = PrefStore.getSessionJWT() {
      headers["x-session"] = jwt
    }
    
    if let locale = CHUtils.getLocale() {
      headers["X-language"] = locale.rawValue
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
    
    if let headers = parameters?["headers"] as? ParametersType,
      var req = try? request.asURLRequest() {
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
    case .GetMessages(_, let params),
         .CreateMessage(_, let params),
         .UploadFile(_, let params),
         .GetUserChats(let params),
         .RegisterToken(let params),
         .UpdateProfileItem(_, let params),
         .Translate(_, let params),
         .CloseUserChat(_, let params),
         .ReviewUserChat(_, let params),
         .ReplySupportBot(_, _, let params),
         .UpdateUser(let params):
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: params)
    case .GetUserChat,
         .GetPlugin,
         .GetPluginWithKey,
         .GetCountryCodes,
         .GetOperators,
         .CreateUserChat,
         .CreateSupportBotChat,
         .SendPushAck,
         .CheckNudgeReach,
         .SetMessagesRead,
         .CreateNudgeChat,
         .GetSupportBot,
         .GetExternalMessengers,
         .GetProfileBotSchemas,
         .KeepNudge,
         .UnregisterToken:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    case .TouchUser:
      urlRequest = try encode(addAuthForSimple(request: urlRequest), with: nil)
    case .Boot(_, let params),
         .SendEvent(_, let params):
      urlRequest = try encode(addAuthForSimple(request: urlRequest), with: params)
    default:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    }
    
    return urlRequest
  }
}
