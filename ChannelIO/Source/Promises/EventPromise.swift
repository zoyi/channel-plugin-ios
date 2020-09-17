//
//  EventPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 28/08/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

struct EventPromise {
  static func sendEvent(
    pluginId: String,
    name: String,
    property: [String: Any?]? = nil) -> Observable<CHEvent> {
    return Observable.create { subscriber in
      var params = [
        "url": [String:String]()
      ]
      
      params["url"]?["name"] = name
      if let property = CHUtils.jsonStringify(data: property) {
        params["url"]?["property"] = property
      }
      if let jwt = PrefStore.getSessionJWT() {
        params["url"]?["sessionJWT"] = jwt
      }

      AF
        .request(RestRouter.SendEvent(pluginId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let event = ObjectMapper_Mapper<CHEvent>()
              .map(JSONObject: json["event"].object) else {
                subscriber.onError(ChannelError.parseError)
                return
            }
            subscriber.onNext(event)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      
      return Disposables.create()
    }
  }
}
