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
  static func requestSupportBots(pluginId: String) -> Observable<[CHSupportBot]?> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.GetSupportBots(pluginId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let supportBots = Mapper<CHSupportBot>().mapArray(JSONObject: json["supportBots"].object)
            
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
  
  static func getSupportBotEntry(supportBotId: String) -> Observable<([CHSupportBotContext], [CHSupportBotAction])> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.GetSupportBotEntry(supportBotId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            subscriber.onNext(([], []))
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
  
  static func createSupportBotUserChat(supportBotId: String) -> Observable<CHUserChat?> {
    return Observable.create({ (subscriber) in
      let req = Alamofire.request(RestRouter.CreateSupportBotChat(supportBotId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let userChat = Mapper<CHUserChat>().map(JSONObject: json["userChat"].object)
            subscriber.onNext(userChat)
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
  
  static func replySupportBot(supportBotId: String, formId: String, key: String) -> Observable<Any?> {
    return Observable.create({ (subscriber) in
      let params = [
        "query": [
          "formId": formId,
          "key": key
        ]
      ]
      let req = Alamofire.request(RestRouter.ReplySupportBot(supportBotId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            
            subscriber.onNext(nil)
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
