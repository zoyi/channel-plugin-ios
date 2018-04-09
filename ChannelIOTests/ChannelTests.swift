//
//  ChannelTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
@testable import CHPlugin

class ChannelTests: QuickSpec {
  
  override func spec() {
    describe("create") {
      it("default") {
        let channel = Channel()
        expect(channel.name).to(equal(""))
        expect(channel.avatarUrl).to(beNil())
        expect(channel.initial).to(equal(""))
        expect(channel.color).to(equal(""))
        expect(channel.country).to(equal(""))
        expect(channel.textColor).to(equal("white"))
        expect(channel.outOfWorkPlugin).notTo(beTrue())
        expect(channel.working).to(beTrue())
        expect(channel.workingTime).to(beNil())
      }
      
      it("normal") {
        let channel = Channel(
          id: "7",
          avatarUrl: "http://www.channel.io",
          initial: "J",
          color: "#298312",
          name: "Joy",
          country: "KR",
          textColor: "#555555",
          outOfWorkPlugin: false,
          working: true,
          workingTime: nil,
          phoneNumber: "0212341234",
          requestGuestInfo: true
        )
        
        expect(channel.name).to(equal("Joy"))
        expect(channel.avatarUrl).to(equal("http://www.channel.io"))
        expect(channel.initial).to(equal("J"))
        expect(channel.color).to(equal("#298312"))
        expect(channel.country).to(equal("KR"))
        expect(channel.textColor).to(equal("#555555"))
        expect(channel.outOfWorkPlugin).notTo(beTrue())
        expect(channel.working).to(beTrue())
        expect(channel.workingTime).to(beNil())
      }

      it("convert correct working time string") {
        // TODO: Write test code
      }
    }
  }
  
}
