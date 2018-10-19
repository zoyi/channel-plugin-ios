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
  static func getSupportBots(pluginId: String) -> Observable<[CHSupportBot]> {
    let params = [
      "query": [
        "mobile": "true"
      ]
    ]
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.GetSupportBots(pluginId, params))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let supportBots = Mapper<CHSupportBot>().mapArray(JSONObject: json["supportBots"].object) ?? []
            
            subscriber.onNext(supportBots)
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
  
  static func getSupportBotEntry(supportBotId: String) -> Observable<CHSupportBotEntryInfo> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.GetSupportBotEntry(supportBotId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let step = Mapper<CHSupportBotStep>().map(JSONObject: json["step"].object)
            let actions = Mapper<CHSupportBotAction>().mapArray(JSONObject: json["actions"].object) ?? []
            let data = CHSupportBotEntryInfo(step: step, actions: actions)
            
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
            guard let chatResponse = Mapper<ChatResponse>()
              .map(JSONObject: json.object) else {
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
  
  static func replySupportBot(userChatId: String?, formId: String?, key: String?) -> Observable<Any?> {
    return Observable.create({ (subscriber) in
      guard let chatId = userChatId, let formId = formId, let key = key else {
        subscriber.onError(CHErrorPool.unknownError)
        return Disposables.create()
      }
      
      let params = [
        "query": [
          "formId": formId,
          "key": key
        ]
      ]
      
      let req = Alamofire.request(RestRouter.ReplySupportBot(chatId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          if response.response?.statusCode == 200 {
            subscriber.onNext(nil)
            subscriber.onCompleted()
          } else {
            subscriber.onError(CHErrorPool.unknownError)
          }
        })
      return Disposables.create {
        req.cancel()
      }
    })
  }
}
