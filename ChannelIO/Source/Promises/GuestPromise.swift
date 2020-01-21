//
//  UserPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON
import ObjectMapper
import CRToast

struct UserPromise {
  static func touch(pluginId: String) -> Observable<BootResponse> {
    return Observable.create { subscriber in
      let req = Alamofire
        .request(RestRouter.TouchUser(pluginId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:JSON = JSON(data)
            guard let result = Mapper<BootResponse>().map(JSONObject: json.object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext(result)
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
  
  static func updateProfile(with profiles:[String: Any?]) -> Observable<(CHUser?, Any?)> {
    return Observable.create { (subscriber) -> Disposable in
      let params = [
        "body": profiles
      ]
      
      let req = Alamofire.request(RestRouter.UpdateUser(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:JSON = JSON(data)
            guard let user = Mapper<CHUser>().map(JSONObject: json["user"].object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext((user, nil))
            subscriber.onCompleted()
          case .failure(let error):
            if let data = response.data {
              CRToastManager.showErrorFromData(data)
            }
            subscriber.onNext((nil, error))
            subscriber.onCompleted()
          }
        })

      return Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func closePopup() -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = Alamofire
        .request(RestRouter.ClosePopup)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
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

