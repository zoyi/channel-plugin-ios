//
//  UIStatetests.swift
//  ChannelIOTests
//
//  Created by Yusuke Konishi on 2020/07/09.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Quick
import Nimble

@testable import ChannelIO

class UIStateTests: QuickSpec {
  override func spec() {
    describe("description") {
      it("return valid value") {
        expect(ChannelPluginCompletionStatus.success.description).to(equal("success"))
        expect(ChannelPluginCompletionStatus.notInitialized.description).to(equal("notInitialized"))
        expect(ChannelPluginCompletionStatus.networkTimeout.description).to(equal("networkTimeout"))
        expect(ChannelPluginCompletionStatus.notAvailableVersion.description).to(equal("notAvailableVersion"))
        expect(ChannelPluginCompletionStatus.serviceUnderConstruction.description).to(equal("serviceUnderConstruction"))
        expect(ChannelPluginCompletionStatus.requirePayment.description).to(equal("requirePayment"))
        expect(ChannelPluginCompletionStatus.accessDenied.description).to(equal("accessDenied"))
        expect(ChannelPluginCompletionStatus.unknown.description).to(equal("unknown"))
      }
    }
  }
}
