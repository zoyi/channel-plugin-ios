//
//  MarketingActions.swift
//  ChannelIO
//
//  Created by intoxicated on 17/02/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

struct ViewMarketing: Action {
  public let type: CHMarketingType?
  public let id: String?
}

struct ClickMarketing: Action {
  public let type: CHMarketingType?
  public let id: String?
}
