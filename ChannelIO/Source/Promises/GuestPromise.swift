//
//  GuestPromise.swift
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

struct GuestPromise {
  static func touch() -> Observable<CHGuest> {
    return Observable.create { subscriber in
      let req = Alamofire.request(RestRouter.TouchGuest)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:JSON = JSON(data)
            
            let user:CHUser? = Mapper<CHUser>().map(JSONObject: json["user"].object)
            let veil:CHVeil? = Mapper<CHVeil>().map(JSONObject: json["veil"].object)
            
            if user == nil && veil == nil {
              subscriber.onError(CHErrorPool.guestParseError)
            } else {
              user == nil ? subscriber.onNext(veil!) : subscriber.onNext(user!)
              subscriber.onCompleted()
            }
            break
          case .failure(let error):
            subscriber.onError(error)
            break
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func updateProfile(with profiles:[String: Any?]) -> Observable<(CHGuest?, Any?)> {
    return Observable.create({ (subscriber) -> Disposable in
      let params = [
        "body": profiles
      ]
      
      let req = Alamofire.request(RestRouter.UpdateGuest(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:JSON = JSON(data)
            
            let user:CHUser? = Mapper<CHUser>().map(JSONObject: json["user"].object)
            let veil:CHVeil? = Mapper<CHVeil>().map(JSONObject: json["veil"].object)
            
            if user == nil && veil == nil {
              subscriber.onError(CHErrorPool.guestParseError)
            } else {
              user != nil ? subscriber.onNext((user, nil)) : subscriber.onNext((veil, nil))
              subscriber.onCompleted()
            }
            break
          case .failure(let error):
            if let data = response.data {
              CRToastManager.showErrorFromData(data)
            }
            subscriber.onNext((nil, error))
            subscriber.onCompleted()
            break
          }
        })
      
      return Disposables.create {
        req.cancel()
      }
    })
  }
}

