//
//  UserChatPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON
import ObjectMapper

struct UserChatPromise {
  static func getChats(
    since:Int64?=nil,
    limit:Int,
    showCompleted: Bool = false) -> Observable<[String: Any?]> {
    return Observable.create { subscriber in
      var params = ["query": [
          "limit": limit,
          "includeClosed": showCompleted
        ]
      ]
      if since != nil {
        params["query"]?["since"] = since
      }

      Alamofire
        .request(RestRouter.GetUserChats(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            //next, managers, sessions, userChats, messages
            let next = json["next"].int64Value
            let managers = Mapper<CHManager>().mapArray(JSONObject: json["managers"].object)
            let sessions = Mapper<CHSession>().mapArray(JSONObject: json["sessions"].object)
            let userChats = Mapper<CHUserChat>().mapArray(JSONObject: json["userChats"].object)
            let messages = Mapper<CHMessage>().mapArray(JSONObject: json["messages"].object)
            let bots = Mapper<CHBot>().mapArray(JSONObject: json["bots"].object)
            
            subscriber.onNext([
              "next":next,
              "managers": managers,
              "sessions": sessions,
              "userChats": userChats,
              "messages": messages,
              "bots": bots
            ])
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func createChat(pluginId: String, url: String) -> Observable<ChatResponse> {
    return Observable.create { subscriber in
      let params = [
        "url": ["url" : url]
      ]
      
      Alamofire
        .request(RestRouter.CreateUserChat(
          pluginId,
          params as RestRouter.ParametersType)
        )
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let chatResponse = Mapper<ChatResponse>()
              .map(JSONObject: json.object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            subscriber.onNext(chatResponse)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return Disposables.create()
    }
  }
  
  static func getChat(userChatId: String) -> Observable<ChatResponse> {
    return Observable.create { subscriber in
      Alamofire
        .request(RestRouter.GetUserChat(userChatId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let chatResponse = Mapper<ChatResponse>()
              .map(JSONObject: json.object) else {
                subscriber.onError(ChannelError.parseError)
                break
              }
            
            subscriber.onNext(chatResponse)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
          
        })
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func close(
    userChatId: String,
    actionId: String,
    requestId: String) -> Observable<CHUserChat> {
    return Observable.create { subscriber in
      let params = [
        "query":[
          "actionId": actionId,
          "requestId": requestId
        ]
      ]
      let req = Alamofire
        .request(RestRouter.CloseUserChat(
          userChatId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let userChat = Mapper<CHUserChat>()
              .map(JSONObject: json["userChat"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            subscriber.onNext(userChat)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
      }
      return Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func review(
    userChatId: String,
    actionId: String,
    rating: ReviewType,
    requestId: String) -> Observable<CHUserChat> {
    return Observable.create { subscriber in
      let params = [
        "url":[
          "review": rating.rawValue,
        ],
        "query":[
          "actionId": actionId,
          "requestId": requestId
        ]
      ]
      
      let req = Alamofire
        .request(RestRouter.ReviewUserChat(
          userChatId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let userChat = Mapper<CHUserChat>().map(JSONObject: json["userChat"].object) else {
              subscriber.onError(ChannelError.parseError)
              break
            }
            
            
            subscriber.onNext(userChat)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
      }
      return Disposables.create {
        req.cancel()
      }
    }
  }

  static func remove(userChatId: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = Alamofire
        .request(RestRouter.RemoveUserChat(userChatId))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        }
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func getMessages(
    userChatId: String,
    since: String,
    limit: Int,
    sortOrder: String) -> Observable<[String: Any]> {
    return Observable.create { subscriber in
      let params = [
        "query": [
          "since": since,
          "limit": limit,
          "sortOrder": sortOrder
        ]
      ]
      
      let req = Alamofire
        .request(RestRouter.GetMessages(userChatId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)

            guard let messages: Array<CHMessage> =
              Mapper<CHMessage>().mapArray(JSONObject: json["messages"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }

            guard let managers: Array<CHManager> =
              Mapper<CHManager>().mapArray(JSONObject: json["managers"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            guard let bots: Array<CHBot> =
              Mapper<CHBot>().mapArray(JSONObject: json["bots"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            let prev = json["previous"].string ?? ""
            let next = json["next"].string ?? ""
            
            subscriber.onNext([
              "messages": messages,
              "managers": managers,
              "bots": bots,
              "previous": prev,
              "next": next
            ])
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func createMessage(
    userChatId: String,
    message: String?,
    requestId: String,
    files: [CHFile]? = nil,
    fileDictionary: [String:Any]? = nil,
    submit: CHSubmit? = nil,
    mutable: Bool? = nil) -> Observable<CHMessage> {
    return Observable.create { subscriber in
      var params = [
        "query": [String: Any](),
        "body": [String: Any]()
      ]
      
      if let files = files, !files.isEmpty {
        params["body"]?["files"] = files.toJSON()
      } else if let fileDictionary = fileDictionary {
        params["body"]?["files"] = [fileDictionary]
      }
      
      if let mutable = mutable {
        params["query"]?["mutable"] = mutable
      }
      
      if let message = message, message != "" {
        params["body"]?["plainText"] = message
      }
      
      if let submit = submit {
        params["body"]?["submit"] = submit.toJSON()
      }
      
      params["body"]?["requestId"] = requestId
      
      let req = Alamofire
        .request(RestRouter.CreateMessage(userChatId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let message = Mapper<CHMessage>()
              .map(JSONObject: json["message"].object) else {
              subscriber.onError(ChannelError.parseError)
              break
            }
            
            subscriber.onNext(message)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func updateMessageProfile(
    userChatId: String,
    messageId: String,
    key: String,
    value: Any) -> Observable<CHMessage> {
    return Observable.create { subscriber in
      let params = [
        "body": [
          key: value
        ]
      ]
      
      let req = Alamofire
        .request(RestRouter.UpdateProfileItem(
          userChatId,
          messageId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let message = Mapper<CHMessage>()
              .map(JSONObject: json["message"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            subscriber.onNext(message)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          }
        })
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func setMessageRead(userChatId: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = Alamofire.request(RestRouter.SetMessagesRead(userChatId))
        .validate(statusCode: 200..<300)
        .responseJSON (completionHandler: { (response) in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          }
        })
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func translate(
    userChatId: String,
    messageId: String,
    language: String) -> Observable<[CHMessageBlock]> {
    return Observable.create { (subscriber) in
      let params = [
        "query": [
          "language": language
        ]
      ]
      let req = Alamofire.request(
        RestRouter.Translate(
          userChatId,
          messageId,
          params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let blocks = Mapper<CHMessageBlock>()
              .mapArray(JSONObject: json["blocks"].object) ?? []

            subscriber.onNext(blocks)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          }
        })
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
}
