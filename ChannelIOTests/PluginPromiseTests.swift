//
//  PluginPromiseTests.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
//import RxSwift

@testable import ChannelIO

class PluginPromiseTests: QuickSpec {
  
  override func spec() {
    describe("Plugin promise") {
      it("should return a response with valid data") {
        waitUntil (timeout: 30) { done in
          let promise = PluginPromise
            .getPluginConfiguration(apiKey: "52eb6f27-38c7-476d-ad92-83e6299b7e07", params: [:])
          _ = promise.subscribe(onNext: { (data) in

          }, onError: { error in
            expect(error).to(beNil())
          }, onCompleted: {
            done()
          })
        }
      }
    }
  }
  
}
