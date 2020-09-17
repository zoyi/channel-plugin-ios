//
//  SupportBotPromise.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

struct SupportBotPromise {  
  static func createSupportBotUserChat(
    supportBotId: String,
    url: String) -> Observable<ChatResponse> {
    let params = [
      "url": ["url" : url]
    ]
    
    return Observable.create { (subscriber) in
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
            guard let chatResponse = Mapper<ChatResponse>()
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
      return Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func replySupportBot(
    userChatId: String?,
    actionId: String?,
    buttonKey: String?,
    requestId: String? = nil) -> Observable<CHMessage> {
    return Observable.create { (subscriber) in
      guard
        let chatId = userChatId,
        let buttonKey = buttonKey,
        let actionId = actionId,
        let requestId = requestId else {
          subscriber.onError(ChannelError.parameterError)
          return Disposables.create()
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
    }
  }
  
  static func startMarketingToSupportBot(
    userChatId: String?,
    supportBotId: String?) -> Observable<CHMessage> {
    guard
      let userChatId = userChatId,
      let supportBotId = supportBotId else {
        return .empty()
      }
    
    return Observable.create { (subscriber) in
      let req = AF
        .request(RestRouter.StartMarketingToSupportBot(userChatId, supportBotId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
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
    }
  }
}
