//
//  MarketingPromise.swift
//  ChannelIO
//
//  Created by intoxicated on 17/02/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Alamofire
import ObjectMapper
import RxSwift
import SwiftyJSON


struct MarketingPromise {
  static func clickCampaign(id: String, userId: String, url: String?) -> Observable<Any?> {
    var params: [String: [String: String]] = [:]
    if let url = url {
      params = [
        "url": ["url" : url]
      ]
    }
      
    return Observable.create { subscriber in
      let req = AF
        .request(RestRouter.CampaignClick(id, userId, params as RestRouter.ParametersType))
        .responseData { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
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
    }
  }
  
  static func viewCampaign(id: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = AF
        .request(RestRouter.CampaignView(id))
        .responseData { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
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
    }
  }
  
  static func clickOneTimeMsg(id: String, userId: String, url: String?) -> Observable<Any?> {
    var params: [String: [String: String]] = [:]
    if let url = url {
      params = [
        "url": ["url" : url]
      ]
    }
    
    return Observable.create { subscriber in
      let req = AF
        .request(RestRouter.OneTimeMsgClick(id, userId, params as RestRouter.ParametersType))
        .responseData { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
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
    }
  }
  
  static func viewOneTimeMsg(id: String) -> Observable<Any?> {
    return Observable.create { subscriber in
      let req = AF
        .request(RestRouter.OneTimeMsgView(id))
        .responseData { response in
          switch response.result {
          case .success(_):
            subscriber.onNext(nil)
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
    }
  }
}
