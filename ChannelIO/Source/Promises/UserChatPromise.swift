//
//  UserChatPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct UserChatPromise {
  static func getChats(
    since: String? = nil,
    limit: Int,
    showCompleted: Bool = false) -> _RXSwift_Observable<UserChatsResponse> {
    return _RXSwift_Observable.create { subscriber in
      var params = ["query": [
          "limit": limit,
          "includeClosed": showCompleted
        ]
      ]
      if let since = since {
        params["query"]?["since"] = since
      }

      AF
        .request(RestRouter.GetUserChats(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let userChatsResponse = ObjectMapper_Mapper<UserChatsResponse>()
              .map(JSONObject: json.object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            
            subscriber.onNext(userChatsResponse)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return _RXSwift_Disposables.create()
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func createChat(pluginId: String, url: String) -> _RXSwift_Observable<ChatResponse> {
    return _RXSwift_Observable.create { subscriber in
      let params = [
        "url": ["url" : url]
      ]
      
      AF
        .request(RestRouter.CreateUserChat(
          pluginId,
          params as RestRouter.ParametersType)
        )
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let chatResponse = ObjectMapper_Mapper<ChatResponse>()
              .map(JSONObject: json.object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            if let id = chatResponse.userChat?.id {
              ChannelIO.delegate?.onChatCreated?(chatId: id)
            }
            subscriber.onNext(chatResponse)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return _RXSwift_Disposables.create()
    }
  }
  
  static func getChat(userChatId: String) -> _RXSwift_Observable<ChatResponse> {
    return _RXSwift_Observable.create { subscriber in
      AF
        .request(RestRouter.GetUserChat(userChatId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let chatResponse = ObjectMapper_Mapper<ChatResponse>()
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
      return _RXSwift_Disposables.create()
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func close(
    userChatId: String,
    actionId: String,
    requestId: String) -> _RXSwift_Observable<CHUserChat> {
    return _RXSwift_Observable.create { subscriber in
      let params = [
        "query":[
          "actionId": actionId,
          "requestId": requestId
        ]
      ]
      let req = AF
        .request(RestRouter.CloseUserChat(
          userChatId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let userChat = ObjectMapper_Mapper<CHUserChat>()
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func review(
    userChatId: String,
    actionId: String,
    rating: ReviewType,
    requestId: String) -> _RXSwift_Observable<CHUserChat> {
    return _RXSwift_Observable.create { subscriber in
      let params = [
        "url":[
          "review": rating.rawValue,
        ],
        "query":[
          "actionId": actionId,
          "requestId": requestId
        ]
      ]
      
      let req = AF
        .request(RestRouter.ReviewUserChat(
          userChatId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let userChat = ObjectMapper_Mapper<CHUserChat>().map(JSONObject: json["userChat"].object) else {
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }

  static func remove(userChatId: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func getMessages(
    userChatId: String,
    since: String?,
    limit: Int,
    sortOrder: String) -> _RXSwift_Observable<[String: Any]> {
    return _RXSwift_Observable.create { subscriber in
      var params = [
        "query": [
          "limit": limit,
          "sortOrder": sortOrder
        ]
      ]
      
      if let since = since {
        params["query"]?["since"] = since
      }
      
      let req = AF
        .request(RestRouter.GetMessages(userChatId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)

            guard let messages: Array<CHMessage> =
              ObjectMapper_Mapper<CHMessage>().mapArray(JSONObject: json["messages"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }

            guard let managers: Array<CHManager> =
              ObjectMapper_Mapper<CHManager>().mapArray(JSONObject: json["managers"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            guard let bots: Array<CHBot> =
              ObjectMapper_Mapper<CHBot>().mapArray(JSONObject: json["bots"].object) else {
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func createMessage(
    userChatId: String,
    message: String?,
    requestId: String,
    files: [CHFile]? = nil,
    fileDictionary: [String:Any]? = nil,
    submit: CHSubmit? = nil,
    mutable: Bool? = nil) -> _RXSwift_Observable<CHMessage> {
    return _RXSwift_Observable.create { subscriber in
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
      
      let req = AF
        .request(RestRouter.CreateMessage(userChatId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let message = ObjectMapper_Mapper<CHMessage>()
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func updateMessageProfile(
    userChatId: String,
    messageId: String,
    key: String,
    value: Any) -> _RXSwift_Observable<CHMessage> {
    return _RXSwift_Observable.create { subscriber in
      let params = [
        "body": [
          key: value
        ]
      ]
      
      let req = AF
        .request(RestRouter.UpdateProfileItem(
          userChatId,
          messageId,
          params as RestRouter.ParametersType
        ))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let message = ObjectMapper_Mapper<CHMessage>()
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func setMessageRead(userChatId: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF.request(RestRouter.SetMessagesRead(userChatId))
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func translate(
    userChatId: String,
    messageId: String,
    language: String) -> _RXSwift_Observable<[CHMessageBlock]> {
    return _RXSwift_Observable.create { (subscriber) in
      let params = [
        "query": [
          "language": language
        ]
      ]
      let req = AF.request(
        RestRouter.Translate(
          userChatId,
          messageId,
          params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            let blocks = ObjectMapper_Mapper<CHMessageBlock>()
              .mapArray(JSONObject: json["blocks"].object) ?? []

            subscriber.onNext(blocks)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          }
        })
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
}
