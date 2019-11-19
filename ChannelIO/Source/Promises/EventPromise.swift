//
//  EventPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 28/08/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import ObjectMapper

struct EventPromise {
  static func sendEvent(
    pluginId: String,
    name: String,
    property: [String: Any?]? = nil,
    sysProperty: [String: Any?]? = nil) -> Observable<CHEvent> {
    return Observable.create { subscriber in
      var params = [
        "url": [String:String]()
      ]
      
      params["url"]?["name"] = name
      if let property = CHUtils.jsonStringify(data: property) {
        params["url"]?["property"] = property
      }
      if let sysProperty = CHUtils.jsonStringify(data: sysProperty) {
        params["url"]?["sysProperty"] = sysProperty
      }
      if let jwt = PrefStore.getSessionJWT() {
        params["url"]?["sessionJWT"] = jwt
      }

      Alamofire.request(RestRouter.SendEvent(pluginId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            guard let event = Mapper<CHEvent>().map(JSONObject: json["event"].object) else {
              subscriber.onError(CHErrorPool.eventParseError)
              return
            }
            subscriber.onNext(event)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create()
    }
  }
}
