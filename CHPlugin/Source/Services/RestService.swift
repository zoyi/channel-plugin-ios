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
  case GetPluginConfiguration(String, ParametersType)
  case GetChannelAvatar(String)
  case UpdateGuest(ParametersType)
  case GetCurrentGuest
  case GetChannelManager(String)
  
  //case GetMessage(String, ParametersType)
  
  case GetScripts()
  
  case GetUserChats(ParametersType)
  case CreateUserChat
  case GetUserChat(String)
  case CloseUserChat(String)
  case RemoveUserChat(String)
  case DoneUserChat(String, ParametersType)
  case GetMessages(String, ParametersType)
  case CreateMessage(String, ParametersType)
  case UploadFile(String, ParametersType)
  case SetMessagesReadAll(String)
  
  case RegisterToken(ParametersType)
  case CheckVersion
  case GetGeoIP
  case UnregisterToken(String)
  
  case SendEvent(ParametersType)
  case GetCountryCodes
  
  //#if DEBUG
  //static let baseURL = EPType.DEV.rawValue
  //#else
  var baseURL: String {
    get {
      var url = EPType.PRODUCTION.rawValue
      if let stage = CHUtils.getCurrentStage() {
        if stage == "PROD" {
          url = EPType.PRODUCTION.rawValue
        } else if stage == "ALPHA" {
          url = EPType.ALPHA.rawValue
        } else if stage == "BETA" {
          url = EPType.BETA.rawValue
        }
      }
      return url
    }
  }
  //#endif
  typealias ParametersType = Parameters
 
  var method: HTTPMethod {
    switch self {
    case .GetPluginConfiguration, .CreateMessage,
         .CreateUserChat, .UploadFile, .RegisterToken,
         .SendEvent:
      return .post
    case .GetChannelAvatar, .GetCurrentGuest,
         .GetMessages, .GetScripts,
         .GetUserChat, .GetChannelManager, .GetUserChats,
         .CheckVersion, .GetGeoIP:
      return .get
    case .UpdateGuest, .SetMessagesReadAll,
         .CloseUserChat, .RemoveUserChat,
         .DoneUserChat, .GetCountryCodes:
      return .put
    case .UnregisterToken:
      return .delete
    }
  }
  
  // MARK: Paths
  var path: String {
    switch self {
    case .GetPluginConfiguration(let apiKey, _):
      return "/app/plugins/\(apiKey)/check_in"
    case .GetChannelAvatar(let channelId):
      return "/app/channels/\(channelId)/avatar"
    case .UpdateGuest:
      return "/app/guests"
    case .GetCurrentGuest:
      return "/app/guests/me"
    case .GetChannelManager(let managerId):
      return "/app/manangers/\(managerId)"
    case .GetScripts:
      return "/app/scripts"
    case .GetUserChats, .CreateUserChat:
      return "/app/user_chats"
    case .GetUserChat(let userChatId):
      return "/app/user_chats/\(userChatId)"
    case .CloseUserChat(let userChatId):
      return "/app/user_chats/\(userChatId)/close"
    case .RemoveUserChat(let userChatId):
      return "/app/user_chats/\(userChatId)/remove"
    case .DoneUserChat(let userChatId, _):
      return "/app/user_chats/\(userChatId)/done"
    case .GetMessages(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages"
    case .CreateMessage(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages"
    case .UploadFile(let userChatId, _):
      return "/app/user_chats/\(userChatId)/messages/file"
    case .SetMessagesReadAll(let userChatId):
      return "/app/user_chats/\(userChatId)/messages/read_all"
    case .RegisterToken:
      return "/app/device_tokens"
    case .CheckVersion:
      return "/packages/com.zoyi.channel.plugin.ios/versions/latest"
    case .GetGeoIP:
      return "/geoip"
    case .UnregisterToken(let key):
      return "/app/device_tokens/ios/\(key)"
    case .SendEvent:
      return "/app/events"
    case .GetCountryCodes:
      return "/countries"
    }
  }
  
  func addAuthHeaders(request: URLRequest) -> URLRequest {
    var req = request
    if let channelId = PrefStore.getCurrentChannelId() {
      req.setValue(channelId, forHTTPHeaderField: "X-Channel-Id")
    }
  
    if let veilId = PrefStore.getCurrentVeilId() {
      req.setValue(veilId, forHTTPHeaderField: "X-Veil-Id")
    }
    
    if let userId = PrefStore.getCurrentUserId() {
      req.setValue(userId, forHTTPHeaderField: "X-User-Id")
    }
    
    return req
  }
  
  // MARK: Encoding
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
    var request = urlRequest
    
    if let body = parameters?["body"] as? ParametersType {
      request = try JSONEncoding.default.encode(urlRequest, with: body)
    }
    
    if let url = parameters?["url"] as? ParametersType {
      request = try URLEncoding.default.encode(urlRequest, with: url)
    }
    
    if let query = parameters?["query"] as? ParametersType {
      request = try CustomQueryEncoding().encode(urlRequest, with: query)
    }
    
    if let paths = parameters?["paths"] as? [String] {
      for path in paths {
        request = request.urlRequest?.url?.absoluteString.appending(path) as! URLRequestConvertible
      }
    }
    
    return request as! URLRequest
  }
  
  // MARK: URLRequestConvertible
  func asURLRequest() throws -> URLRequest {
    let url = try self.baseURL.asURL()
    
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    
    switch self {
    case .GetPluginConfiguration(_, let params):
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: params)
    case .UpdateGuest(let params), .GetMessages(_, let params),
         .CreateMessage(_, let params), .UploadFile(_, let params),
         .GetUserChats(let params), .RegisterToken(let params),
         .DoneUserChat(_, let params),
         .SendEvent(let params):
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: params)
    case .GetUserChat, .GetScripts, .SetMessagesReadAll:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    default:
      urlRequest = try encode(addAuthHeaders(request: urlRequest), with: nil)
    }
    return urlRequest
  }

}

