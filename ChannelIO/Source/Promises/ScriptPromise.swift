//
//  ScriptPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import ObjectMapper

struct ScriptPromise {
  static func get(pluginId: String, scriptKey: String) -> Observable<CHScript?> {
    return Observable.create { subscriber in
      let req = Alamofire.request(RestRouter.GetScript(pluginId, scriptKey))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let script = Mapper<CHScript>().map(JSONObject: json["script"].object)
            subscriber.onNext(script)
            subscriber.onCompleted()
            break
          case .failure(let error):
            subscriber.onError(error)
            break
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    }
  }
  static func getAll(pluginId: String) -> Observable<[CHScript]> {
    return Observable.create { subscriber in
      let req = Alamofire.request(RestRouter.GetScripts(pluginId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            guard let scripts: Array<CHScript> = Mapper<CHScript>()
              .mapArray(JSONObject: json["scripts"].object) else {
                subscriber.onError(CHErrorPool.scriptParseError)
                break
            }
            subscriber.onNext(scripts)
            subscriber.onCompleted()
            break
          case .failure(let error):
            subscriber.onError(error)
            break
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
}
