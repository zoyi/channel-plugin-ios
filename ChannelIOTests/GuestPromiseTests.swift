//
//  GuestPromiseTests.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//


import Quick
import Nimble
//import RxSwift

@testable import ChannelIO

class GuestPromiseTests: QuickSpec {
  
  override func spec() {
    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "7")
      PrefStore.setCurrentUserId(userId: "214") //this veil mapped to 214
    }
    
    it("normal") {
      waitUntil (timeout: 10) { done in
        _ = GuestPromise.getCurrent()
          .subscribe(onNext: { (data) in
            
          }, onError: { (error) in
            expect(error).to(beNil())
          }, onCompleted: {
            done()
          })
      }
    }
    
    it("update") {
      waitUntil (timeout: 10) { done in
        var veil = CHVeil()
        veil.mobileNumber = "+821093123291"
        veil.name = "Woohoo"
        _ = GuestPromise.update(user: veil)
          .subscribe(onNext: { (data, error) in
            expect(error).to(beNil())
            
            let user = data as! CHUser
            expect(user.name).to(equal(veil.name))
            expect(user.mobileNumber).to(equal(veil.mobileNumber))
          }, onError: { (error) in
            expect(error).to(beNil())
          }, onCompleted: {
            done()
          })
      }
    }
      
    
  }
}
