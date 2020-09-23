//
//  LoungePromise.swift
//  ChannelIO
//
//  Created by Jam on 2019/11/21.
//

//import RxSwift

struct LoungePromise {
  static func getLounge(pluginId: String, url: String) -> _RXSwift_Observable<LoungeResponse> {
    return _RXSwift_Observable.create { subscriber in
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
            guard let info = ObjectMapper_Mapper<LoungeResponse>().map(JSONObject: json.object) else {
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos: .background))
  }
}
