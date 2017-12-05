//
//  PluginPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import ObjectMapper
import SwiftyJSON

struct PluginPromise {  
  static func getPluginConfiguration (
    apiKey: String,
    params: [String: Any]) -> Observable<[String: Any]> {
    return Observable.create { subscriber in
      
      Alamofire.request(RestRouter.GetPluginConfiguration(
          apiKey, params as RestRouter.ParametersType)
        )
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            var result:[String: Any] = [String: Any]()
            
            result["user"] = Mapper<CHUser>()
              .map(JSONObject: json["user"].object)
            result["veil"] = Mapper<CHVeil>()
              .map(JSONObject: json["veil"].object)
            if result["user"] == nil && result["veil"] == nil {
              subscriber.onError(CHErrorPool.pluginParseError)
              break
            }
            
            result["channel"] = Mapper<CHChannel>()
              .map(JSONObject: json["channel"].object)
            result["plugin"] = Mapper<CHPlugin>()
              .map(JSONObject: json["plugin"].object)
            if result["channel"] == nil || result["plugin"] == nil {
              subscriber.onError(CHErrorPool.pluginParseError)
              break
            }

            result["veilId"] = json["veilId"].string

            subscriber.onNext(result)
            subscriber.onCompleted()
            break
          case .failure(let error):
            subscriber.onError(error)
            break
          }
        })
      
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func registerPushToken(channelId: String, token: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let key = UIDevice.current.identifierForVendor?.uuidString
      let params = [
        "body": [
          "channelId": channelId,
          "key": key,
          "token": token,
          "platform": "ios"
        ]
      ]
      
      Alamofire.request(RestRouter.RegisterToken(
          params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            if json["deviceToken"] == JSON.null {
              subscriber.onError(CHErrorPool.registerParseError)
            }

            subscriber.onNext(nil)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func unregisterPushToken() -> Observable<Any?> {
    return Observable.create { subscriber in
      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      
      Alamofire.request(RestRouter.UnregisterToken(key))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          if response.response?.statusCode == 200 {
            subscriber.onNext(nil)
            subscriber.onCompleted()
          } else {
            subscriber.onError(CHErrorPool.unregisterError)
          }
        })
      
      return Disposables.create()
    }
  }
  
  static func checkVersion() -> Observable<Any?> {
    return Observable.create { subscriber in
      
      Alamofire.request(RestRouter.CheckVersion)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            
            let nsObject: Any = Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? ""
            //Then just cast the object as a String, but be careful, you may want to double check for nil
            let version = nsObject as! String
            let minVersion = json["minCompatibleVersion"].string ?? ""
            
            //if minVersion is higher than version
            if version.versionToInt().lexicographicallyPrecedes(minVersion.versionToInt()) {
              subscriber.onError(CHErrorPool.versionError)
              return
            }
            
            subscriber.onNext(nil)
            subscriber.onCompleted()
            break
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      
      return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func getFollowingManagers() -> Observable<[CHManager]> {
    return Observable.create({ (subscriber) in
      
      Alamofire.request(RestRouter.GetFollowingManager)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = JSON(data)
            let managers = Mapper<CHManager>()
              .mapArray(JSONObject: json["managers"].object)
            subscriber.onNext(managers ?? [])
          case .failure(let error):
            subscriber.onError(error)
          }
        })
      return Disposables.create()
    })
  }
}
