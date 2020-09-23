//
//  PluginPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct PluginPromise {
  static func registerPushToken(token: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      let params = [
        "body": [
          "key": "ios-" + key,
          "token": token
        ]
      ]
      
      let req = AF
        .request(RestRouter.RegisterToken(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            if json["pushToken"] == SwiftyJSON_JSON.null {
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func unregisterPushToken() -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in

      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      let req = AF
        .request(RestRouter.UnregisterToken("ios-\(key)"))
        .validate(statusCode: 200..<300)
        .response { response in
          if let error = response.error {
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          } else {
            subscriber.onNext(nil)
            subscriber.onCompleted()
          }
        }
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func deletePushToken(with userId: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let key = UIDevice.current.identifierForVendor?.uuidString ?? ""
      let params = [
        "query": [
          "userId": userId
        ]
      ]
      
      let req = AF
        .request(RestRouter.DeleteToken("ios-\(key)", params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .response { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.init(data: response.data, error: error))
          }
        }
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func checkVersion() -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
        .request(RestRouter.CheckVersion)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }

  static func getPlugin(pluginKey: String) -> _RXSwift_Observable<(CHPlugin, CHBot?)> {
    return _RXSwift_Observable.create { (subscriber) in
      let req = AF
        .request(RestRouter.GetPlugin(pluginKey))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result{
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let plugin = ObjectMapper_Mapper<CHPlugin>()
              .map(JSONObject: json["plugin"].object) else {
                subscriber.onError(ChannelError.parseError)
                return
              }
            let bot = ObjectMapper_Mapper<CHBot>()
              .map(JSONObject: json["bot"].object)
            subscriber.onNext((plugin, bot))
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
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func boot(pluginKey: String, params: CHParam) -> _RXSwift_Observable<BootResponse?> {
    return _RXSwift_Observable.create { (subscriber) in
      let req = AF
        .request(RestRouter.Boot(pluginKey, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            let result = ObjectMapper_Mapper<BootResponse>().map(JSONObject: json.object)
            
            subscriber.onNext(result)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(
              msg: error.localizedDescription
            ))
          }
        }
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }.subscribeOn(_RXSwift_ConcurrentDispatchQueueScheduler(qos:.background))
  }
  
  static func sendPushAck(chatId: String?) -> _RXSwift_Observable<Bool?> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      guard let chatId = chatId else {
        subscriber.onNext(nil)
        return _RXSwift_Disposables.create()
      }
      
      let req = AF
        .request(RestRouter.SendPushAck(chatId))
        .validate(statusCode: 200..<300)
        .response { response in
          if let error = CHUtils.getServerErrorMessage(data: response.data)?.first {
            subscriber.onError(ChannelError.serverError(msg: error))
          } else if let error = response.error {
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          } else {
            subscriber.onNext(true)
            subscriber.onCompleted()
          }
        }
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func getProfileSchemas(pluginId: String) -> _RXSwift_Observable<[CHProfileSchema]> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      let req = AF
        .request(RestRouter.GetProfileBotSchemas(pluginId))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            let profiles = ObjectMapper_Mapper<CHProfileSchema>()
              .mapArray(JSONObject: json["profileBotSchemas"].object) ?? []
            subscriber.onNext(profiles)
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
