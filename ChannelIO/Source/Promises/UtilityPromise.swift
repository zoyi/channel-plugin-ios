//
//  UtilityPromise.swift
//  CHPlugin
//
//  Created by Haeun Chung on 24/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

struct UtilityPromise {
  static func getGeoIP() -> Observable<GeoIPInfo> {
    return Observable.create { subscriber in
      AF
        .request(RestRouter.GetGeoIP)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json = SwiftyJSON_JSON(data)
            guard let geoData: GeoIPInfo = Mapper<GeoIPInfo>()
              .map(JSONObject: json["geoIp"].object) else {
                subscriber.onError(ChannelError.parseError)
                break
            }
            
            subscriber.onNext(geoData)
            subscriber.onCompleted()
            break
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
            break
          }
          
        })
      return Disposables.create()
    }
  }
  
  static func getCountryCodes() -> Observable<[CHCountry]> {
    return Observable.create { subscriber in
      if mainStore.state.countryCodeState.codes.count != 0 {
        let countries = mainStore.state.countryCodeState.codes
        subscriber.onNext(countries)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      AF
        .request(RestRouter.GetCountryCodes)
        .validate(statusCode: 200..<300)
        .responseData(completionHandler: { (response) in
          switch response.result {
          case .success(let data):
            let json:SwiftyJSON_JSON = SwiftyJSON_JSON(data)
            guard let countries =  Mapper<CHCountry>()
              .mapArray(JSONObject: json.object) else {
                subscriber.onNext([])
                subscriber.onCompleted()
                return
            }
            
            subscriber.onNext(countries)
            subscriber.onCompleted()
          case .failure(let error):
            subscriber.onError(ChannelError.serverError(msg: error.localizedDescription))
          }
          
        })
      return Disposables.create()
    }
  }
}
