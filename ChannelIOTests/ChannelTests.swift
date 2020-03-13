//
//  ChannelTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
import ObjectMapper

@testable import ChannelIO

class ChannelTests: QuickSpec {
  var loadedChannel: CHChannel?
  
  override func spec() {
    beforeEach {
      //TODO: need to find a way to add file witout adding main target
      guard
        let url = Bundle(for: ChannelIO.self).url(forResource: "channel", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let json = try? JSON(data: data) else {
          return
        }
      
      let channel = Mapper<CHChannel>().map(JSONObject: json["channel"].object)
      self.loadedChannel = channel
    }
    
    describe("default creation") {
      context("when using default constructor") {
        it("should contain default values") {
          let channel = CHChannel()
          expect(channel.name).to(equal(""))
          expect(channel.avatarUrl).to(beNil())
          expect(channel.initial).to(equal(""))
          expect(channel.color).to(equal(""))
          expect(channel.country).to(equal(""))
          expect(channel.textColor).to(equal("white"))
          expect(channel.working).to(beTrue())
          expect(channel.workingTime).to(beNil())
        }
      }
    }
    
    describe("load from mock file") {
      context("setting properties") {
        it("should contain proper values") {
          guard let channel = self.loadedChannel else {
            fatalError()
          }
          
          expect(channel.name).to(equal("ZOYI"))
          expect(channel.country).to(equal("KR"))
          expect(channel.workingTime).notTo(beNil())
          expect(channel.timeZone).to(equal("Asia/Seoul"))
        }
      }
    }
    
    describe("") {
      context("canUseSDK") {
        it("should return true if all state is valid") {
          self.loadedChannel?.messengerPlan = .pro
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUseSDK).to(beTrue())
          
          self.loadedChannel?.messengerPlan = .none
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUseSDK).to(beTrue())
          
          self.loadedChannel?.messengerPlan = .pro
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUseSDK).to(beTrue())
        }
        
        it("should return false if channel is block") {
          self.loadedChannel?.blocked = true
          expect(self.loadedChannel?.canUseSDK).to(beFalse())
        }
        
        it("should return false if channel is not pro and not trial") {
          self.loadedChannel?.messengerPlan = .none
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUseSDK).to(beFalse())
        }
      }
    }
    
    describe("") {
      context("canUsePushBot") {
        it("should return true if all state is valid") {
          self.loadedChannel?.pushBotPlan = .pro
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUsePushBot).to(beTrue())
          
          self.loadedChannel?.pushBotPlan = .none
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUsePushBot).to(beTrue())
          
          self.loadedChannel?.pushBotPlan = .pro
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUsePushBot).to(beTrue())
        }
        
        it("should return false if channel is block") {
          self.loadedChannel?.blocked = true
          expect(self.loadedChannel?.canUsePushBot).to(beFalse())
        }
        
        it("should return false if channel is not pro and not trial") {
          self.loadedChannel?.pushBotPlan = .none
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUsePushBot).to(beFalse())
        }
      }
    }
    
    describe("") {
      context("canUseSupportBot") {
        it("should return true if all state is valid") {
          self.loadedChannel?.supportBotPlan = .pro
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUseSupportBot).to(beTrue())
          
          self.loadedChannel?.supportBotPlan = .none
          self.loadedChannel?.trial = true
          expect(self.loadedChannel?.canUseSupportBot).to(beTrue())
          
          self.loadedChannel?.supportBotPlan = .pro
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUseSupportBot).to(beTrue())
        }
        
        it("should return false if channel is block") {
          self.loadedChannel?.blocked = true
          expect(self.loadedChannel?.canUseSupportBot).to(beFalse())
        }
        
        it("should return false if channel is not pro and not trial") {
          self.loadedChannel?.supportBotPlan = .none
          self.loadedChannel?.trial = false
          expect(self.loadedChannel?.canUseSupportBot).to(beFalse())
        }
      }
    }
    
    describe("") {
      context("launcher") {
        it("should hide launcher if away and not working") {
          self.loadedChannel?.awayOption = .hidden
          self.loadedChannel?.working = false
          expect(self.loadedChannel?.shouldHideLauncher).to(beTrue())
        }
      }
    }

    describe("") {
      context("allow new message") {
        it("should return false if away option is not active") {
          self.loadedChannel?.awayOption = .disabled
          self.loadedChannel?.working = false
          expect(self.loadedChannel?.allowNewChat).to(beFalse())
        }
      }
    }
    
    describe("") {
      context("shouldShowWorkingTime") {
        it("should return true if not working and has working hours") {
          self.loadedChannel?.working = false
          expect(self.loadedChannel?.shouldShowWorkingTimes).to(beTrue())
        }
      }
    }
    
    describe("") {
      context("working time") {
        it("should return structure working time dictionary") {
          expect(self.loadedChannel?.workingTime).notTo(beNil())
        }
      }
    }
    
    describe("") {
      context("getClosetWorkingTime") {
        it("should return next weekday and hour left") {
          let next = self.loadedChannel?.closestWorkingTime(from: Date())
          expect(next).notTo(beNil())
        }
        
        it("should return nil if away if custom and not working") {
          self.loadedChannel?.workingType = .never
          self.loadedChannel?.working = false
          let next = self.loadedChannel?.closestWorkingTime(from: Date())
          expect(next).to(beNil())
        }
      }
    }
  }
}
