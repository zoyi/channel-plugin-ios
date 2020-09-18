//
//  CHMarketing.swift
//  ChannelIO
//
//  Created by Jam on 2020/01/20.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import ObjectMapper
import RxSwift

typealias MarketingInfo = (type: CHMarketingType?, id: String?)

enum CHMarketingType: String {
  case campaign
  case oneTimeMsg
}

struct CHMarketing {
  var type: CHMarketingType?
  var id: String = ""
  var enableSupportBot: Bool = false
  var advertising: Bool = false
  var exposureType: InAppNotificationType = .banner
}

extension CHMarketing: Mappable {
  init?(map: Map) { }

  mutating func mapping(map: Map) {
    type              <- map["type"]
    id                <- map["id"]
    enableSupportBot  <- map["enableSupportBot"]
    advertising       <- map["advertising"]
    exposureType      <- map["exposureType"]
  }
}

extension CHMarketing: Equatable {
  static func == (lhs: CHMarketing, rhs: CHMarketing) -> Bool {
    return lhs.type == rhs.type &&
      lhs.id == rhs.id &&
      lhs.enableSupportBot == rhs.enableSupportBot &&
      lhs.advertising == rhs.advertising &&
      lhs.exposureType == rhs.exposureType
  }
}

extension CHMarketing {
  func fetchSupportBot() -> Observable<CHSupportBot?> {
    if self.type == .campaign {
      return MarketingPromise.getCampaignSupportBot(with: id)
    } else {
      return MarketingPromise.getOneTimeMsgSupportBot(with: id)
    }
  }
}
