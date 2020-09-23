//
//  UserPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct UserPromise {
  static func touch(pluginId: String) -> _RXSwift_Observable<BootResponse> {
    return _RXSwift_Observable.create { subscriber in
      
      var params = [
        "url": [String:String]()
      ]
      
      if let jwt = PrefStore.getSessionJWT() {
        params["url"]?["sessionJWT"] = jwt
      }
      
      let req = AF
        .request(RestRouter.TouchUser(pluginId, params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let result = ObjectMapper_Mapper<BootResponse>().map(JSONObject: json.object) else {
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func updateUser(
    profile: [String: Any?]? = nil,
    profileOnce: [String: Any?]? = nil,
    tags: [String]? = nil,
    unsubscribed: Bool? = nil,
    language: String? = nil) -> _RXSwift_Observable<(CHUser?, ChannelError?)> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      var params = [
        "body": [String: Any]()
      ]
      if let profile = profile?
        .mapValues ({ (value) -> AnyObject? in return value as AnyObject? }) {
        params["body"]?["profile"] = profile
      }
      
      if let profileOnce = profileOnce?
        .mapValues ({ (value) -> AnyObject? in return value as AnyObject? }) {
        params["body"]?["profileOnce"] = profileOnce
      }
      
      if let tags = tags {
        params["body"]?["tags"] = tags
      }
      
      if let unsubscribed = unsubscribed {
        params["body"]?["unsubscribed"] = unsubscribed
      }
      
      if let language = language {
        params["body"]?["language"] = language
      }
      
      let req = AF.request(RestRouter.UpdateUser(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let user = ObjectMapper_Mapper<CHUser>().map(JSONObject: json["user"].object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext((user, nil))
            subscriber.onCompleted()
          case .failure(let error):
            if let error =  CHUtils.getServerErrorMessage(data: response.data)?.first {
              subscriber.onNext((nil, ChannelError.serverError(msg: error)))
            } else {
              subscriber.onNext((nil, ChannelError.serverError(msg: error.localizedDescription)))
            }
            subscriber.onCompleted()
          }
        })

      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func updateUser(param: UpdateUserParam) -> _RXSwift_Observable<(CHUser?, ChannelError?)> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      let req = AF.request(RestRouter.UpdateUser(param as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let user = ObjectMapper_Mapper<CHUser>().map(JSONObject: json["user"].object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext((user, nil))
            subscriber.onCompleted()
          case .failure(let error):
            if let error =  CHUtils.getServerErrorMessage(data: response.data)?.first {
              subscriber.onNext((nil, ChannelError.serverError(msg: error)))
            } else {
              subscriber.onNext((nil, ChannelError.serverError(msg: error.localizedDescription)))
            }
            subscriber.onCompleted()
          }
        })

      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func addTags(tags: [String]?) -> _RXSwift_Observable<(CHUser?, ChannelError?)> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      let params = [
        "query": ["tags": tags]
      ]
      
      let req = AF.request(RestRouter.AddTags(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let user = ObjectMapper_Mapper<CHUser>().map(JSONObject: json["user"].object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext((user, nil))
            subscriber.onCompleted()
          case .failure(let error):
            if let error =  CHUtils.getServerErrorMessage(data: response.data)?.first {
              subscriber.onNext((nil, ChannelError.serverError(msg: error)))
            } else {
              subscriber.onNext((nil, ChannelError.serverError(msg: error.localizedDescription)))
            }
            subscriber.onCompleted()
          }
        })

      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func removeTags(tags: [String]?) -> _RXSwift_Observable<(CHUser?, ChannelError?)> {
    return _RXSwift_Observable.create { (subscriber) -> _RXSwift_Disposable in
      let params = [
        "query": ["tags": tags]
      ]
      
      let req = AF.request(RestRouter.RemoveTags(params as RestRouter.ParametersType))
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let user = ObjectMapper_Mapper<CHUser>().map(JSONObject: json["user"].object) else {
              subscriber.onError(ChannelError.parseError)
              return
            }
            subscriber.onNext((user, nil))
            subscriber.onCompleted()
          case .failure(let error):
            if let error =  CHUtils.getServerErrorMessage(data: response.data)?.first {
              subscriber.onNext((nil, ChannelError.serverError(msg: error)))
            } else {
              subscriber.onNext((nil, ChannelError.serverError(msg: error.localizedDescription)))
            }
            subscriber.onCompleted()
          }
        })

      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func closePopup() -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
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
      
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
}

