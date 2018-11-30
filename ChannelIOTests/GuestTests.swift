//
//  GuestTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
@testable import ChannelIO

class GuestTests: QuickSpec {
  
  override func spec() {
    
    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "7")
      PrefStore.setCurrentVeilId(veilId: "58a154dec843f78f")
      PrefStore.clearCurrentUserId()
    }
    
    describe("general") {
//      it("get current") {
//        PrefStore.setCurrentUserId(userId: "214")
//        waitUntil (timeout: 30) { done in
//          _ = CHUser.getCurrent()
//            .subscribe(onNext: { (result) in
//            expect(result).to(beAKindOf(CHUser.self))
//            let user = result as! CHUser
//
//            expect(user.id).to(equal("214"))
//            done()
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//        }
//      }
    }
    
    describe("User") {
      it("default") {
        let user = CHUser()
        
        expect(user.id).to(equal(""))
        expect(user.name).to(equal(""))
        expect(user.avatarUrl).to(beNil())
        expect(user.mobileNumber).to(beNil())
      }
      
      it("normal") {
        let user = CHUser(id: "123", name: "user",
                        avatarUrl: "www.zoyi.co",
                        named: false,
                        mobileNumber: "+8201032314123",
                        profile: ["userInfo":"test"])
        
        expect(user.id).to(equal("123"))
        expect(user.name).to(equal("user"))
        expect(user.avatarUrl).to(equal("www.zoyi.co"))
        expect(user.mobileNumber).to(equal("+8201032314123"))
      }
      
      it("update") {
//        PrefStore.setCurrentUserId(userId: "214")
//
//        var user = CHUser()
//        user.name = "Intoxicated"
//        user.mobileNumber = "+821093123291"
//        waitUntil (timeout: 10) { done in
//          _ = user
//            .subscribe(onNext: { (result, error) in
//            expect(error).to(beNil())
//            expect(result).to(beAKindOf(CHUser.self))
//            let user = result as! CHUser
//
//            expect(user.id).to(equal("214"))
//            expect(user.name).to(equal("Intoxicated"))
//            expect(user.mobileNumber).to(equal("+821093123291"))
//            done()
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//        }
      }
    }
    
    describe("Veil") {
      it("default") {
        let veil = CHVeil()
        
        expect(veil.id).to(equal(""))
        expect(veil.name).to(equal(""))
        expect(veil.avatarUrl).to(beNil())
        expect(veil.mobileNumber).to(beNil())
      }
      
      it("normal") {
        let veil = CHVeil(id: "123", name: "user",
                        avatarUrl: "www.zoyi.co",
                        named: false,
                        mobileNumber: "+8201032314123",
                        profile: ["userInfo":"test"])
        expect(veil.id).to(equal("123"))
        expect(veil.name).to(equal("user"))
        expect(veil.avatarUrl).to(equal("www.zoyi.co"))
        expect(veil.mobileNumber).to(equal("+8201032314123"))
      }
    }
  }
  
}
