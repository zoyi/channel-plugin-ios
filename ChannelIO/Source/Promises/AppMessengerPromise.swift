//
//  AppMessengerPromise.swift
//  ChannelIO
//
//  Created by Jam on 2020/02/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

//import RxSwift

struct AppMessengerPromise {
  static func getUri(with name: String) -> _RXSwift_Observable<UriResponse> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
        .request(RestRouter.GetAppMessengerUri(name))
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let uri = ObjectMapper_Mapper<UriResponse>().map(JSONObject: json.object) else {
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos: .background))
  }
}
