//
//  UserPromiseTests.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//


import Quick
import Nimble
//import RxSwift

@testable import ChannelIO

class UserPromiseTests: QuickSpec {
  
  override func spec() {
    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "7")
      PrefStore.setCurrentUserId(userId: "214") //this user mapped to 214
    }
    
    it("normal") {
//      waitUntil (timeout: 10) { done in
//        _ = UserPromise.getCurrent()
//          .subscribe(onNext: { (data) in
//
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          }, onCompleted: {
//            done()
//          })
//      }
    }
    
    it("update") {

    }
      
    
  }
}
