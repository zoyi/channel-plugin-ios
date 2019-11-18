//
//  NudgePromise.swift
//  ChannelIO
//
//  Created by Haeun Chung on 12/11/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import ObjectMapper

struct NudgePromise {
  static func requestReach(nudgeId: String) -> Observable<NudgeReachResponse> {
    return Observable.create { (subscriber) in
      let req = Alamofire.request(RestRouter.CheckNudgeReach(nudgeId))
        .validate(statusCode: 200..<300)
        .asyncResponse(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            guard let result = Mapper<NudgeReachResponse>()
              .map(JSONObject: json.object) else {
              subscriber.onError(CHErrorPool.chatResponseParseError)
              break
            }
            subscriber.onNext(result)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func createNudgeUserChat(nudgeId: String) -> Observable<ChatResponse> {
    return Observable.create { (subscriber) in
      let req = Alamofire.request(RestRouter.CreateNudgeChat(nudgeId))
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
    }
  }
}
