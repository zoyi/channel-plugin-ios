//
//  ChannelPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper
import SwiftyJSON

struct ChannelPromise {
  static func getManager(channelId: String) -> Observable<Any?> {
    return Observable.create { observer in
      return Disposables.create()
    }
  }
  
  static func getChannel() -> Observable<CHChannel> {
    return Observable.create({ (subscriber) -> Disposable in
      let req = Alamofire.request(RestRouter.GetChannel)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = JSON(data)
            guard let channel = Mapper<CHChannel>()
              .map(JSONObject: json["channel"].object) else { return }
            
            subscriber.onNext(channel)
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
  
  static func getExternalMessengers() -> Observable<[CHExternalSourceType: String]?> {
    return Observable.create({ (subscriber) -> Disposable in
      let req = Alamofire.request(RestRouter.GetExternalMessengers)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = JSON(data)
            guard let res = json.dictionaryObject as? [String: String] else {
              subscriber.onNext(nil)
              subscriber.onCompleted()
              return
            }
            
            var linkDict: [CHExternalSourceType: String] = [:]
            for (key, value) in res {
              if let key = CHExternalSourceType(rawValue: key) {
                linkDict[key] = value
              }
            }
            
            subscriber.onNext(linkDict)
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
