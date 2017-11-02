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
  static func get() -> Observable<[CHScript]> {
    return Observable.create { subscriber in
      Alamofire.request(RestRouter.GetScripts())
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
      
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
}
