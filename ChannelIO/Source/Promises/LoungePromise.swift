//
//  LoungePromise.swift
//  ChannelIO
//
//  Created by Jam on 2019/11/21.
//

import RxSwift
import ObjectMapper

struct LoungePromise {
  static func getLounge(pluginId: String, url: String) -> Observable<LoungeResponse> {
    return Observable.create { subscriber in
      let params = [
        "url": ["url": url]
      ]
      
      let req = AF
        .request(RestRouter.GetLounge(pluginId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let info = Mapper<LoungeResponse>().map(JSONObject: json.object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext(info)
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
