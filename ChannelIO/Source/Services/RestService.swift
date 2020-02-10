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
  case CreateUserChat(String, ParametersType)
  case ClosePopup
  case CloseUserChat(String, ParametersType)
  case CreateMessage(String, ParametersType)
  case CheckVersion
  case CreateSupportBotChat(String, ParametersType)
  case GetPlugin(String)
  case GetGeoIP
  case GetChannel
  case GetCountryCodes
  case GetLounge(String, ParametersType)
  case GetUserChats(ParametersType)
  case GetUserChat(String)
  case GetMessages(String, ParametersType)
  case GetProfileBotSchemas(String)
  case ReplySupportBot(String, String, ParametersType)
  case RegisterToken(ParametersType)
  case RemoveUserChat(String)
  case ReviewUserChat(String, ParametersType)
  case SendEvent(String, ParametersType)
  case SetMessagesRead(String)
  case SendPushAck(String)
  case TouchUser(String)
  case Translate(String, String, ParametersType)
  case UpdateUser(ParametersType)
  case UpdateProfileItem(String, String, ParametersType)
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
         .UpdateProfileItem,
         .TouchUser,
         .CreateSupportBotChat, .ReplySupportBot,
         .GetLounge:
      return .post
    case .GetMessages, .GetUserChat,
         .GetUserChats, .CheckVersion, .GetGeoIP,
         .GetCountryCodes,
         .GetPlugin,
         .Translate,
         .GetProfileBotSchemas,
         .GetChannel:
      return .get
    case .UpdateUser:
      return .patch
    case .CloseUserChat,
         .ReviewUserChat,
         .SetMessagesRead,
         .SendPushAck:
      return .put
    case .ClosePopup,
         .UnregisterToken,
         .RemoveUserChat:
      return .delete
    }
  }
  
  // MARK: Paths
  var path: String {
    let channelId = RestRouter.channelId
    
    switch self {
    case .Boot(let pluginKey, _):
      return "/front/plugins/\(pluginKey)/boot"
    case .CreateUserChat(let pluginId, _):
      return "/front/plugins/\(pluginId)/user-chats"
    case .CreateSupportBotChat(let supportBotId, _):
      return "/front/support-bots/\(supportBotId)/user-chats"
    case .CreateMessage(let userChatId, _):
      return "/front/user-chats/\(userChatId)/messages"
    case .CheckVersion:
      return "/packages/com.zoyi.channel.plugin.ios/versions/latest"
    case .ClosePopup:
      return "/front/users/me/pop-up"
    case .CloseUserChat(let userChatId, _):
      return "/front/user-chats/\(userChatId)/close"
    case .GetMessages(let userChatId, _):
      return "/front/user-chats/\(userChatId)/messages"
    case .GetCountryCodes:
      return "/available/countries"
    case .GetChannel:
      return "/front/channels/\(channelId)"
    case .GetLounge(let pluginId, _):
      return "/front/plugins/\(pluginId)/lounge"
    case .GetPlugin(let pluginKey):
      return "/front/plugins/\(pluginKey)"
    case .GetUserChats:
      return "/front/user-chats"
    case .GetGeoIP:
      return "/geoip"
    case .GetUserChat(let userChatId):
      return "/front/user-chats/\(userChatId)"
    case .GetProfileBotSchemas(let pluginId):
      return "/front/plugins/\(pluginId)/profile-bot-schemas"
    case .RemoveUserChat(let userChatId):
      return "/front/user-chats/\(userChatId)"
    case .ReviewUserChat(let userChatId, _):
      return "/front/user-chats/\(userChatId)/review"
    case .RegisterToken:
      return "/front/push-tokens"
    case .ReplySupportBot(let userChatId, let buttonKey, _):
      return "/front/user-chats/\(userChatId)/support-bot/buttons/\(buttonKey)"
    case .SetMessagesRead(let userChatId):
      return "/front/user-chats/\(userChatId)/messages/read"
    case .SendPushAck(let userChatId):
      return "/front/user-chats/\(userChatId)/messages/receive"
    case .SendEvent(let pluginId, _):
      return "/front/plugins/\(pluginId)/events"
    case .Translate(let userChatId, let messageId, _):
      return "/front/user-chats/\(userChatId)/messages/\(messageId)/translate"
    case .TouchUser(let pluginId):
      return "/front/plugins/\(pluginId)/touch"
    case .UpdateProfileItem(let userChatId, let messageId, _):
      return "/front/user-chats/\(userChatId)/messages/\(messageId)/profile-bot"
    case .UploadFile(let userChatId, _):
      return "/front/user-chats/\(userChatId)/messages/file"
    case .UpdateUser(_):
      return "/front/users/me"
    case .UnregisterToken(let key):
      return "/front/push-tokens/\(key)"
    }
  }
  
  func addAuthForSimple(request: URLRequest, isBoot: Bool = false) -> URLRequest {
    var req = request
    var headers = req.allHTTPHeaderFields ?? [String: String]()
    
    headers["Accept"] = "application/json"
    
    if let locale = CHUtils.getLocale(), isBoot {
      headers["Accept-Language"] = locale.rawValue
    }
    
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
      headers["Accept-language"] = locale.rawValue
    }
    
    headers["Accept"] = "application/json"
    headers["User-Agent"] = CHUtils.generateUserAgent()
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
         .CreateUserChat(_, let params),
         .CreateSupportBotChat(_, let params),
         .UploadFile(_, let params),
         .GetUserChats(let params),
         .GetLounge(_, let params),
         .RegisterToken(let params),
         .UpdateProfileItem(_, _, let params),
         .Translate(_, _, let params),
         .ReviewUserChat(_, let params),
         .ReplySupportBot(_, _, let params),
         .UpdateUser(let params):
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: params)
    case .GetUserChat,
         .GetPlugin,
         .GetCountryCodes,
         .ClosePopup,
         .SendPushAck,
         .SetMessagesRead,
         .GetProfileBotSchemas,
         .UnregisterToken:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    case .TouchUser:
      urlRequest = try encode(addAuthForSimple(request: urlRequest), with: nil)
    case .SendEvent(_, let params):
      urlRequest = try encode(addAuthForSimple(request: urlRequest), with: params)
    case .Boot(_, let params):
      urlRequest = try encode(addAuthForSimple(request: urlRequest, isBoot: true), with: params)
    default:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    }
    
    return urlRequest
  }
}
