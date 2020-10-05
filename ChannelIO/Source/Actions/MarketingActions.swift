//
//  MarketingActions.swift
//  ChannelIO
//
//  Created by intoxicated on 17/02/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

struct ViewMarketing: ReSwift_Action {
  let type: CHMarketingType?
  let id: String?
}

struct ClickMarketing: ReSwift_Action {
  let type: CHMarketingType?
  let id: String?
}
