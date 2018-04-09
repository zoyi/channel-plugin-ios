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
  static func getCurrent() -> Observable<CHGuest> {
    return Observable.create { subscriber in
      Alamofire.request(RestRouter.GetCurrentGuest)
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

      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func update(user: CHGuest) -> Observable<(CHGuest?, Any?)> {
    //assert input is either user or veil
    assert(user is CHUser || user is CHVeil)
    return Observable.create { subscriber in
      var params = [
        "body": [String:AnyObject?]()
      ]
      params["body"]?["name"] = user.name as AnyObject?
      params["body"]?["mobileNumber"] = user.mobileNumber as AnyObject?
      
      request(RestRouter.UpdateGuest(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:JSON = JSON(data)

            let veil:CHVeil? = Mapper<CHVeil>().map(JSONObject: json["veil"].object)
            let user:CHUser? = Mapper<CHUser>().map(JSONObject: json["user"].object)
            if veil == nil && user == nil {
              subscriber.onNext((nil,CHErrorPool.guestParseError))
              break
            }
            
            user != nil ? subscriber.onNext((user!, nil)) : subscriber.onNext((veil!, nil))
            subscriber.onCompleted()
            break
          case .failure(let error):
            if let data = response.data {
              CRToastManager.dismissAllNotifications(false)
              CRToastManager.showErrorFromData(data)
            }
            subscriber.onNext((nil,error))
            break
          }
        })
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
 
}

