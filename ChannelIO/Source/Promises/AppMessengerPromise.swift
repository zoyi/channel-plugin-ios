//
//  AppMessengerPromise.swift
//  ChannelIO
//
//  Created by Jam on 2020/02/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Alamofire
import RxSwift
import SwiftyJSON
import ObjectMapper

struct AppMessengerPromise {
  static func getUri(with name: String) -> Observable<UriResponse> {
    return Observable.create { subscriber in
      let req = AF
        .request(RestRouter.GetAppMessengerUri(name))
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            guard let uri = Mapper<UriResponse>().map(JSONObject: json.object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext(uri)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
  }
}
