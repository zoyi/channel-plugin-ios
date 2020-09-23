//
//  MarketingPromise.swift
//  ChannelIO
//
//  Created by intoxicated on 17/02/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

//import RxSwift

struct MarketingPromise {
  static func clickCampaign(id: String, userId: String, url: String?) -> _RXSwift_Observable<Any?> {
    var params: [String: [String: String]] = [:]
    if let url = url {
      params = [
        "url": ["url" : url]
      ]
    }
      
    return _RXSwift_Observable.create { subscriber in
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func viewCampaign(id: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func getCampaignSupportBot(with campaignId: String) -> _RXSwift_Observable<CHSupportBotEntryInfo> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
        .request(RestRouter.GetCampaignSupportBot(campaignId))
        .validate(statusCode: 200..<300)
        .responseData { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let supportBot = ObjectMapper_Mapper<CHSupportBotEntryInfo>().map(JSONObject: json) else {
              subscriber.onError(ChannelError.parseError)
              break
            }
            subscriber.onNext(supportBot)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.init(data: response.data, error: error))
          }
      }
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func clickOneTimeMsg(id: String, userId: String, url: String?) -> _RXSwift_Observable<Any?> {
    var params: [String: [String: String]] = [:]
    if let url = url {
      params = [
        "url": ["url" : url]
      ]
    }
    
    return _RXSwift_Observable.create { subscriber in
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func viewOneTimeMsg(id: String) -> _RXSwift_Observable<Any?> {
    return _RXSwift_Observable.create { subscriber in
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
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
  
  static func getOneTimeMsgSupportBot(with oneTimeMsgId: String) -> _RXSwift_Observable<CHSupportBotEntryInfo> {
    return _RXSwift_Observable.create { subscriber in
      let req = AF
        .request(RestRouter.GetOneTimeMsgSupportBot(oneTimeMsgId))
        .validate(statusCode: 200..<300)
        .responseData { response in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard
              let supportBot = ObjectMapper_Mapper<CHSupportBotEntryInfo>().map(JSONObject: json.object)
            else {
              subscriber.onError(ChannelError.parseError)
              break
            }
            subscriber.onNext(supportBot)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.init(data: response.data, error: error))
          }
      }
      return _RXSwift_Disposables.create {
        req.cancel()
      }
    }
  }
}
