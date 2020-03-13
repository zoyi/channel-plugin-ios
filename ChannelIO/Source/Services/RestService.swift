//
//  RestService.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire

enum RestRouter: URLRequestConvertible {
  case Boot(String, ParametersType)
  case CreateUserChat(String, ParametersType)
  case ClosePopup
  case CloseUserChat(String, ParametersType)
  case CreateMessage(String, ParametersType)
  case CheckVersion
  case CreateSupportBotChat(String, ParametersType)
  case CampaignClick(String)
  case CampaignView(String)
  case GetAppMessengerUri(String)
  case GetPlugin(String)
  case GetGeoIP
  case GetChannel
  case GetCountryCodes
  case GetLounge(String, ParametersType)
  case GetUserChats(ParametersType)
  case GetUserChat(String)
  case GetMessages(String, ParametersType)
  case GetProfileBotSchemas(String)
  case OneTimeMsgClick(String)
  case OneTimeMsgView(String)
  case ReplySupportBot(String, String, ParametersType)
  case RegisterToken(ParametersType)
  case RemoveUserChat(String)
  case ReviewUserChat(String, ParametersType)
  case SendEvent(String, ParametersType)
  case SetMessagesRead(String)
  case SendPushAck(String)
  case StartMarketingToSupportBot(String, String)
  case TouchUser(String, ParametersType)
  case Translate(String, String, ParametersType)
  case UpdateUser(ParametersType)
  case UpdateProfileItem(String, String, ParametersType)
  case UnregisterToken(String)
  case UploadFile(String, ParametersType)
  
  var baseURL: String {
    get {
      return CHUtils.getCurrentStage().restEndPoint
    }
  }

  typealias ParametersType = Parameters
  static let queue = DispatchQueue(label: "com.zoyi.channel.restapi", qos: .background, attributes: .concurrent)
  static let packageName = "com.zoyi.channel.plugin.ios"
  static var channelId = ""
  
  var method: HTTPMethod {
    switch self {
    case .Boot,
         .CreateMessage,
         .CreateUserChat,
         .CreateSupportBotChat,
         .GetLounge,
         .ReplySupportBot,
         .RegisterToken,
         .SendEvent,
         .StartMarketingToSupportBot,
         .TouchUser,
         .UpdateProfileItem,
         .UploadFile:
      return .post
    case .CheckVersion,
         .GetAppMessengerUri,
         .GetCountryCodes,
         .GetGeoIP,
         .GetMessages,
         .GetUserChat,
         .GetUserChats,
         .GetPlugin,
         .GetProfileBotSchemas,
         .GetChannel,
         .Translate:
      return .get
    case .UpdateUser:
      return .patch
    case .CampaignClick,
         .CampaignView,
         .CloseUserChat,
         .OneTimeMsgClick,
         .OneTimeMsgView,
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
      return "/front/elastic/plugins/\(pluginKey)/boot"
    case .CampaignClick(let campaignId):
      return "/front/campaigns/\(campaignId)/click"
    case .CampaignView(let campaignId):
      return "/front/campaigns/\(campaignId)/view"
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
    case .GetAppMessengerUri(let name):
      return "/front/app/\(name)/connect"
    case .GetMessages(let userChatId, _):
      return "/front/user-chats/\(userChatId)/messages"
    case .GetCountryCodes:
      return "/available/countries"
    case .GetChannel:
      return "/front/channels/\(channelId)"
    case .GetLounge(let pluginId, _):
      return "/front/plugins/\(pluginId)/lounge"
    case .GetPlugin(let pluginKey):
      return "/front/elastic/plugins/\(pluginKey)"
    case .GetUserChats:
      return "/front/user-chats"
    case .GetGeoIP:
      return "/request/geo-ip"
    case .GetUserChat(let userChatId):
      return "/front/user-chats/\(userChatId)"
    case .GetProfileBotSchemas(let pluginId):
      return "/front/plugins/\(pluginId)/profile-bot-schemas"
    case .OneTimeMsgClick(let oneTimeMsgId):
      return "/front/one-time-msgs/\(oneTimeMsgId)/click"
    case .OneTimeMsgView(let oneTimeMsgId):
      return "/front/one-time-msgs/\(oneTimeMsgId)/view"
    case .RemoveUserChat(let userChatId):
      return "/front/user-chats/\(userChatId)"
    case .ReviewUserChat(let userChatId, _):
      return "/front/user-chats/\(userChatId)/review"
    case .RegisterToken:
      return "/front/elastic/push-tokens"
    case .ReplySupportBot(let userChatId, let buttonKey, _):
      return "/front/user-chats/\(userChatId)/support-bot/buttons/\(buttonKey)"
    case .SetMessagesRead(let userChatId):
      return "/front/user-chats/\(userChatId)/messages/read"
    case .SendPushAck(let userChatId):
      return "/front/user-chats/\(userChatId)/messages/receive"
    case .SendEvent(let pluginId, _):
      return "/front/elastic/plugins/\(pluginId)/events"
    case .StartMarketingToSupportBot(let userChatId, let supportBotId):
      return "/front/user-chats/\(userChatId)/support-bots/\(supportBotId)"
    case .Translate(let userChatId, let messageId, _):
      return "/front/user-chats/\(userChatId)/messages/\(messageId)/translate"
    case .TouchUser(let pluginId, _):
      return "/front/elastic/plugins/\(pluginId)/touch"
    case .UpdateProfileItem(let userChatId, let messageId, _):
      return "/front/user-chats/\(userChatId)/messages/\(messageId)/profile-bot"
    case .UploadFile(let userChatId, _):
      return "/front/user-chats/\(userChatId)/messages/file"
    case .UpdateUser(_):
      return "/front/users/me"
    case .UnregisterToken(let key):
      return "/front/elastic/push-tokens/\(key)"
    }
  }
  
  func addAuthForSimple(request: URLRequest) -> URLRequest {
    var req = request
    var headers = req.allHTTPHeaderFields ?? [String: String]()
    
    if let locale = CHUtils.getLocale() {
      headers["Accept-Language"] = locale.rawValue
    }
    
    headers["Accept"] = "application/json"
    
    headers["User-Agent"] = CHUtils.generateUserAgent()
    
    if let version = CHUtils.getSdkVersion() {
      headers["x-channel-sdk"] = "ios/" + version
    }
    
    if let hostApp = CHUtils.getHostAppInfo() {
      headers["x-host-app"] = hostApp
    }
    
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
    
    if let version = CHUtils.getSdkVersion() {
      headers["x-channel-sdk"] = "ios/" + version
    }
    
    if let hostApp = CHUtils.getHostAppInfo() {
      headers["x-host-app"] = hostApp
    }
    
    req.allHTTPHeaderFields = headers
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
         .CloseUserChat(_, let params),
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
    case .GetAppMessengerUri,
         .GetUserChat,
         .GetPlugin,
         .GetCountryCodes,
         .ClosePopup,
         .SendPushAck,
         .SetMessagesRead,
         .StartMarketingToSupportBot,
         .GetProfileBotSchemas,
         .UnregisterToken:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    case .Boot(_, let params),
         .TouchUser(_, let params),
         .SendEvent(_, let params):
      urlRequest = try encode(addAuthForSimple(request: urlRequest), with: params)
    default:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    }
    
    return urlRequest
  }
}
