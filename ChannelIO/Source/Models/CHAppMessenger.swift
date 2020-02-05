//
//  CHAppMessenger.swift
//  ChannelIO
//
//  Created by Jam on 2020/02/05.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import ObjectMapper
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

extension CHAppMessenger: Mappable {
  init?(map: Map) {}

  mutating func mapping(map: Map) {
    id                <- map["id"]
    iconKey           <- map["iconKey"]
    name              <- map["name"]
  }
}

extension CHAppMessenger {
  var iconUrl: URL? {
    var url = AssetEndPointType.production.rawValue
    switch CHUtils.getCurrentStage() {
    case .development:
      url = AssetEndPointType.exp.rawValue
    case .staging:
      url = AssetEndPointType.stage.rawValue
    case .production:
      url = AssetEndPointType.production.rawValue
    }
    return URL(string: url + "/" + iconKey)
  }
  
  static func getUri(with name: String) -> Observable<UriResponse> {
    return AppMessengerPromise.getUri(with: name)
  }
}
