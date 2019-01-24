//
//  SupportBotPromise.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import ObjectMapper

struct SupportBotPromise {
  static func getSupportBot(pluginId: String) -> Observable<CHSupportBotEntryInfo> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.GetSupportBot(pluginId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let supportBot = Mapper<CHSupportBot>().map(JSONObject: json["supportBot"].object)
            let step = Mapper<CHSupportBotStep>().map(JSONObject: json["step"].object)
            let buttons = Mapper<CHActionButton>().mapArray(JSONObject: json["buttons"].object) ?? []
            let data = CHSupportBotEntryInfo(supportBot: supportBot, step: step, buttons: buttons)

            subscriber.onNext(data)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    })
  }
  
  static func createSupportBotUserChat(supportBotId: String) -> Observable<ChatResponse> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.CreateSupportBotChat(supportBotId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            guard let chatResponse = Mapper<ChatResponse>().map(JSONObject: json.object) else {
              subscriber.onError(CHErrorPool.chatResponseParseError)
              break
            }
            subscriber.onNext(chatResponse)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      return Disposables.create {
        req.cancel()
      }
    })
  }
  
  static func replySupportBot(userChatId: String?, actionId: String?, buttonId: String?, requestId: String? = nil) -> Observable<CHMessage> {
    return Observable.create({ (subscriber) in
      guard let chatId = userChatId, let buttonId = buttonId, let actionId = actionId , let requestId = requestId else {
        subscriber.onError(CHErrorPool.unknownError)
        return Disposables.create()
      }
      
      let params = [
        "query": [
          "requestId": requestId,
          "actionId": actionId
        ]
      ]
      
      let req = Alamofire.request(RestRouter.ReplySupportBot(chatId, buttonId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            guard let message = Mapper<CHMessage>().map(JSONObject: json["message"].object) else {
              subscriber.onError(CHErrorPool.messageParseError)
              break
            }
            subscriber.onNext(message)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      return Disposables.create {
        req.cancel()
      }
    })
  }
}
