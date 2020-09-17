//
//  CHAppMessenger.swift
//  ChannelIO
//
//  Created by Jam on 2020/02/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift

enum AssetEndPointType: String {
  case production = "https://cf.channel.io"
  case exp = "http://cf.exp.channel.io"
  case stage = "http://cf.staging.channel.io"
}

struct CHAppMessenger: ModelType {
  var id: String = ""
  var iconKey: String = ""
  var name: String = ""
}

extension CHAppMessenger: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}

  mutating func mapping(map: ObjectMapper_Map) {
    id                <- map["id"]
    iconKey           <- map["iconKey"]
    name              <- map["name"]
  }
}

extension CHAppMessenger {
  var iconUrl: URL? {
    let key = iconKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    guard let keyUrl = key else { return nil }
    
    var url = AssetEndPointType.production.rawValue
    switch CHUtils.getCurrentStage() {
    case .development:
      url = AssetEndPointType.exp.rawValue
    case .staging:
      url = AssetEndPointType.stage.rawValue
    case .production:
      url = AssetEndPointType.production.rawValue
    }
    return URL(string: url + "/" + keyUrl)
  }
  
  static func getUri(with name: String) -> Observable<UriResponse> {
    return AppMessengerPromise.getUri(with: name)
  }
}
