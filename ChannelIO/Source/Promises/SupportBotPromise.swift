//
//  SupportBotPromise.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct SupportBotPromise {  
  static func createSupportBotUserChat(
    supportBotId: String,
    url: String) -> _RXSwift_Observable<ChatResponse> {
    let params = [
      "url": ["url" : url]
    ]
    
    return _RXSwift_Observable.create { (subscriber) in
      let req = AF
        .request(RestRouter.CreateSupportBotChat(
          supportBotId,
          params as RestRouter.ParametersType)
        )
        .validate(statusCode: 200..<300)
        .responseJSON { (response) in
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
        }
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func replySupportBot(
    userChatId: String?,
    actionId: String?,
    buttonKey: String?,
    requestId: String? = nil) -> _RXSwift_Observable<CHMessage> {
    return _RXSwift_Observable.create { (subscriber) in
      guard
        let chatId = userChatId,
        let buttonKey = buttonKey,
        let actionId = actionId,
        let requestId = requestId else {
          subscriber.onError(ChannelError.parameterError)
          return _RXSwift_Disposables.create()
        }
      
      let params = [
        "query": [
          "requestId": requestId,
          "actionId": actionId
        ]
      ]
      
      let req = AF
        .request(RestRouter.ReplySupportBot(
          chatId,
          buttonKey,
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
    }
  }
  
  static func startMarketingToSupportBot(
    userChatId: String?,
    supportBotId: String?) -> _RXSwift_Observable<CHMessage> {
    guard
      let userChatId = userChatId,
      let supportBotId = supportBotId else {
        return .empty()
      }
    
    return _RXSwift_Observable.create { (subscriber) in
      let req = AF
        .request(RestRouter.StartMarketingToSupportBot(userChatId, supportBotId))
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
    }
  }
}
