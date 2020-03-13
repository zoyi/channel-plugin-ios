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
  let defaultInterval: TimeInterval = 1.0
  
  // change both to valid conditionplugin key
  private let validPluginKey = "06ccfc12-a9fd-4c68-b364-5d19f81a60dd"
  private let freePluginKey = "f6747e65-d3d0-4177-b2eb-13b9ff21c2e1"
  private let blockedPluginKey = ""
  
  private var onChangeBadgeCalled: Bool = false
  private var onChangeBadgeCount: Int = -1
  private var onReceivePushCalled: Bool = false
  private var onReceivePushEvent: PushEvent = PushEvent(with: CHPush())

  private var settings = ChannelPluginSettings()
  
  override func spec() {
    beforeSuite {
      ChannelIO.delegate = self
    }
    
    beforeEach {
      self.settings = ChannelPluginSettings()
      self.settings.pluginKey = self.validPluginKey
      
      self.onChangeBadgeCalled = false
      self.onChangeBadgeCount = -1
      self.onReceivePushCalled = false
      self.onReceivePushEvent = PushEvent(with: CHPush())
    }
    
    afterEach {
      if ChannelIO.isBooted {
        ChannelIO.shutdown()
      }
    }
    
    describe("boot process") {
      context("when dealing with pluginKey") {
        it("should return 'not initialized' status if not valid") {
          self.settings.pluginKey = ""

          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, user) in
              expect(status).to(equal(.notInitialized))
              expect(user).to(beNil())
              done()
            }
          }
        }
        
        it("should return success status and user object if valid") {
          let settings = ChannelPluginSettings()
          settings.pluginKey = "b84452ae-f2ad-4488-bf46-ac9619fa2012"

          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, user) in
              expect(status).to(equal(.success))
              expect(user).notTo(beNil())
              done()
            }
          }
        }
        
        it("should return requirePayment status if messenger plan is not pro") {
          self.settings.pluginKey = self.freePluginKey
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, user) in
              expect(status).to(equal(.requirePayment))
              expect(user).to(beNil())
              done()
            }
          }
        }
      }

      context("when dealing with locale") {
        it("should have default language as locale if not provided") {
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, user) in
              expect(ChannelIO.settings?.locale).to(equal(.english))
              done()
            }
          }
        }
        
        it("should have provided language as locale if it is set") {
          self.settings.locale = .japanese
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: settings, profile: nil) { (status, user) in
              expect(ChannelIO.settings?.locale).to(equal(.japanese))
              done()
            }
          }
        }
      }
      
      context("when dealing with launcher configure") {
        it("should have default configure if not provided") {
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: nil) { (_, _) in
              expect(ChannelIO.settings?.launcherConfig).to(beNil())
              done()
            }
          }
        }
        
        it("should have provided configure if it is set") {
          self.settings.launcherConfig = LauncherConfig(
            position: .left, xMargin: 100, yMargin: 200
          )
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: nil) { (_, _) in
              expect(ChannelIO.settings?.launcherConfig?.xMargin).to(equal(100))
              expect(ChannelIO.settings?.launcherConfig?.yMargin).to(equal(200))
              done()
            }
          }
        }
      }
      
      context("when dealing with profile") {
        it("should have default configure if not provided") {
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: nil) { (_, _) in
              expect(ChannelIO.profile).to(beNil())
              done()
            }
          }
        }
        
        it("should have provided configure if it is set") {
          let profile = Profile()
          profile.set(name: "TESTER")
          profile.set(avatarUrl: "test.com")
          profile.set(mobileNumber: "01012341234")
          profile.set(email: "test@test.com")
          profile.set(propertyKey: "age", value: 1231231)
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: profile) { (_, _) in
              expect(ChannelIO.profile?.name).to(equal("TESTER"))
              expect(ChannelIO.profile?.avatarUrl).to(equal("test.com"))
              expect(ChannelIO.profile?.mobileNumber).to(equal("01012341234"))
              expect(ChannelIO.profile?.email).to(equal("test@test.com"))
              expect(ChannelIO.profile?.property["age"]).notTo(beNil())
              done()
            }
          }
        }
      }
    }
    
    describe("shutdown process") {
      context("when shutdown after boot") {
        it("should have empty settings") {
          self.boot()
          expect(ChannelIO.isBooted).to(beTrue())
          expect(PrefStore.getCurrentChannelId()).notTo(beNil())
          expect(PrefStore.getChannelPluginSettings()).notTo(beNil())
          
          ChannelIO.shutdown()
          expect(ChannelIO.isBooted)
            .toEventually(beFalse(), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
          expect(PrefStore.getCurrentChannelId())
            .toEventually(beNil(), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
          expect(PrefStore.getChannelPluginSettings())
            .toEventually(beNil(), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
        }
      }
    }
    
    describe("updateGuest process") {
      context("when dealing with new profile") {
        it("should return nil if it called before boot") {
          ChannelIO.updateGuest(["name": "test"]) { (_, guest) in
            expect(guest).to(beNil())
          }
        }
        
        it("should have proper profile if guest not exist") {
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: nil) { (_, _) in
              ChannelIO.updateGuest(["name": "test"]) { (status, guest) in
                expect(guest?.name).to(equal("test"))
                done()
              }
            }
          }
        }
        
        it("should have changed profile if guest exist already") {
          let profile = Profile()
          profile.set(name: "TESTER")
          
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: profile) { (_, firstGuest) in
              expect(firstGuest?.name).to(equal("TESTER"))
              
              ChannelIO.updateGuest(["name": "test"]) { (status, guest) in
                expect(guest?.name).to(equal("test"))
                done()
              }
            }
          }
        }
      }
    }
    
    describe("initPushToken process") {
      context("when dealing with token string") {
        it("should has proper token string ") {
          self.boot()
          
          ChannelIO.initPushToken(tokenString: "test")
          expect(ChannelIO.pushToken)
            .toEventually(equal("test"), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
        }
      }
    }
    
    describe("handleBadge process") {
      context("when change badge count") {
        it("should called and has proper count") {
          expect(self.onChangeBadgeCalled).to(beFalse())
          expect(self.onChangeBadgeCount).to(equal(-1))
          
          var alert = 0
          waitUntil(timeout: self.defaultTimeout) { done in
            ChannelIO.boot(with: self.settings, profile: nil) { (_, guest) in
              alert = guest?.alert ?? -1
              done()
            }
          }
          expect(self.onChangeBadgeCalled)
            .toEventually(beTrue(), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
          expect(self.onChangeBadgeCount)
            .toEventually(equal(alert), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
        }
      }
    }
    
    describe("handlePush process") {
      context("when receive push event") {
        it("should called and has proper evnet") {
          expect(self.onReceivePushCalled).to(beFalse())
          expect(self.onReceivePushEvent.message).to(equal(""))
          
          self.boot()
          var push = CHPush()
          push.message = CHMessage(chatId: "1", message: "test_message", type: .Default)
          mainStore.dispatch(GetPush(payload: push))
          expect(self.onReceivePushCalled)
            .toEventually(beTrue(), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
          expect(self.onReceivePushEvent.message)
            .toEventually(equal("test_message"), timeout: self.defaultTimeout, pollInterval: self.defaultInterval)
        }
      }
    }
  }
}

extension APITests {
  private func boot() {
    waitUntil(timeout: self.defaultTimeout) { done in
      ChannelIO.boot(with: self.settings, profile: nil) { (_, _) in
        done()
      }
    }
  }
}

extension APITests: ChannelPluginDelegate {
  func onChangeBadge(count: Int) -> Void {
    self.onChangeBadgeCalled = true
    self.onChangeBadgeCount = count
  }
  
  func onReceivePush(event: PushEvent) -> Void {
    self.onReceivePushCalled = true
    self.onReceivePushEvent = event
  }
}
