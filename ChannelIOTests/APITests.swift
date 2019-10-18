//
//  APITests.swift
//  ChannelIOTests
//
//  Created by R3alFr3e on 10/14/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Quick
import Nimble

@testable import ChannelIO

class APITests: QuickSpec {
  let defaultTimeout: TimeInterval = 10.0
  
  let validPluginKey = "b84452ae-f2ad-4488-bf46-ac9619fa2012"
  let freePluginKey = "2f39c9a9-3070-412c-bee9-c1363e5edaea"
  let blockedPluginKey = ""
  
  override func spec() {
    describe("boot process") {
      context("when dealing with pluginKey") {
        it("should return 'not initialized' status if not valid") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = ""

          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, guest) in
              expect(status).to(equal(.notInitialized))
              expect(guest).to(beNil())
              done()
            }
          }
        }
        
        it("should return success status and guest object if valid") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = "b84452ae-f2ad-4488-bf46-ac9619fa2012"

          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, guest) in
              expect(status).to(equal(.success))
              expect(guest).notTo(beNil())
              done()
            }
          }
        }
        
        it("should return requirePayment status if messenger plan is not pro") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = "2f39c9a9-3070-412c-bee9-c1363e5edaea"
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, guest) in
              expect(status).to(equal(.requirePayment))
              expect(guest).to(beNil())
              done()
            }
          }
        }
      }

      context("when dealing with locale") {
        it("should has default language as locale if not provided") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = self.validPluginKey
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, guest) in
              expect(ChannelIO.settings?.locale).to(equal(.english))
              done()
            }
          }
        }
        
        it("should has provided language as locale if it is set") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = self.validPluginKey
          settings.locale = .japanese
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, guest) in
              expect(ChannelIO.settings?.locale).to(equal(.japanese))
              done()
            }
          }
        }
      }
    }
  }
}
