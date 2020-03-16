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
  static func getChannel() -> Observable<CHChannel> {
    return Observable.create { (subscriber) -> Disposable in
      let req = AF
        .request(RestRouter.GetChannel)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = JSON(data)
            guard let channel = Mapper<CHChannel>()
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
      return Disposables.create {
        req.cancel()
      }
    }
  }
}
