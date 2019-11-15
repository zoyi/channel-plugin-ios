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
    sysProperty: [String: Any?]? = nil) -> Observable<(CHEvent, [CHNudge])> {
    return Observable.create { subscriber in
      var params = [
        "body": [String:AnyObject]()
      ]
      
      var event = [String: Any]()
      event["name"] = name
      
      if let property = property, property.count != 0 {
        event["property"] = property
      }
      
      if let sysProperty = sysProperty, sysProperty.count != 0 {
        event["sysProperty"] = sysProperty
      }
      
      params["body"]?["event"] = event as AnyObject?
      params["body"]?["user"] = mainStore.state.user.dict as AnyObject?
      
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
            let nudges = Mapper<CHNudge>().mapArray(JSONObject: json["nudgeCandidates"].object) ?? []
            
            subscriber.onNext((event, nudges))
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create()
    }
  }
}
