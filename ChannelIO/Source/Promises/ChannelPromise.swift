//
//  ChannelPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct ChannelPromise {
  static func getChannel() -> _RXSwift_Observable<CHChannel> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      let req = AF
        .request(RestRouter.GetChannel)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let channel = ObjectMapper_Mapper<CHChannel>()
              .map(JSONObject: json["channel"].object) else {
                subscriber.onError(ChannelError.parseError)
                return
            }
            
            subscriber.onNext(channel)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        })
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
}
