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
  static func registerPushToken(token: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      let params = [
        "body": [
          "key": "ios-" + key,
          "token": token,
          "appVersion": CHUtils.getSdkVersion()
        ]
      ]
      
      let req = Alamofire
        .request(RestRouter.RegisterToken(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            if json["pushToken"] == JSON.null {
              subscriber.onError(ChannelError.parseError)
              return
            }

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
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func unregisterPushToken() -> Observable<Any?> {
    return Observable.create { subscriber in

      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      let req = Alamofire
        .request(RestRouter.UnregisterToken(key))
        .validate(statusCode: 200..<300)
        .response { response in
          if let error = response.error {
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          } else {
            subscriber.onNext(nil)
            subscriber.onCompleted()
          }
        }
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func checkVersion() -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = Alamofire
        .request(RestRouter.CheckVersion)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = JSON(data)
            let minVersion = json["minCompatibleVersion"].string ?? ""
            
            guard let version = CHUtils.getSdkVersion() else {
              subscriber.onError(ChannelError.versionError)
              return
            }
            
            if version.versionToInt().lexicographicallyPrecedes(minVersion.versionToInt()) {
              subscriber.onError(ChannelError.versionError)
              return
            }
            
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
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func getPlugin(pluginKey: String) -> Observable<(CHPlugin, CHBot?)> {
    return Observable.create { (subscriber) in
      let req = Alamofire
        .request(RestRouter.GetPlugin(pluginKey))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = JSON(data)
            guard let plugin = Mapper<CHPlugin>()
              .map(JSONObject: json["plugin"].object) else {
                subscriber.onError(ChannelError.parseError)
                return
              }
            let bot = Mapper<CHBot>()
              .map(JSONObject: json["bot"].object)
            subscriber.onNext((plugin, bot))
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
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func boot(pluginKey: String, params: CHParam) -> Observable<BootResponse?> {
    return Observable.create { (subscriber) in
      let req = Alamofire
        .request(RestRouter.Boot(pluginKey, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let result = Mapper<BootResponse>().map(JSONObject: json.object)
            
            subscriber.onNext(result)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        }
      
      return Disposables.create {
        req.cancel()
      }
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func sendPushAck(chatId: String?) -> Observable<Bool?> {
    return Observable.create { (subscriber) -> Disposable in
      guard let chatId = chatId else {
        subscriber.onNext(nil)
        return Disposables.create()
      }
      
      let req = Alamofire
        .request(RestRouter.SendPushAck(chatId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(_):
            subscriber.onNext(true)
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
  
  static func getProfileSchemas(pluginId: String) -> Observable<[CHProfileSchema]> {
    return Observable.create { (subscriber) -> Disposable in
      let req = Alamofire
        .request(RestRouter.GetProfileBotSchemas(pluginId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON.JSON(data)
            let profiles = Mapper<CHProfileSchema>()
              .mapArray(JSONObject: json["profileBotSchemas"].object) ?? []
            subscriber.onNext(profiles)
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
