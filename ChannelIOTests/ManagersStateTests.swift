//
//  ManagersStateTests.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
//import RxSwift
//import ReSwift

@testable import ChannelIO

class ManagersStateTests: QuickSpec {
  override func spec() {
    var state = ManagersState()
    var managers: [CHManager]? = nil
    
    beforeEach {
      managers = [CHManager]()
//      for i in 0..<10 {
//        let manager = CHManager(id: "\(i)",
//          name: "manager \(i)", avatarUrl: nil,
//          initial: "M \(i)", color: "#123456",
//          username: "man \(i)")
//        
//        managers?.append(manager)
//      }
//      
//      state = ManagersState()
//      state = state.upsert(managers: managers!)
    }

    describe("findBy") {
      
      it("id") {
        let find = state.findBy(id: "1")
        
        expect(find).notTo(beNil())
        expect(find?.initial).to(equal("M 1"))
        expect(find?.username).to(equal("man 1"))
      }
      
      it("ids") {
        let find = state.findBy(ids: ["1", "2"])
        
        expect(find).notTo(beNil())
        expect(find.count).to(equal(2))
      }
      
    }
    
    it("remove") {
      state = state.remove(managerId: "1")
      
      let find = state.findBy(id: "1")
      
      expect(find).to(beNil())
      expect(state.managerDictionary.count).to(equal(9))
    }
    
    describe("upsert") {

      it("insert new") {
//        let manager = CHManager(id: "123",
//          name: "manager 123", avatarUrl: nil,
//          initial: "M 123", color: "#123456",
//          username: "man 123")
//
//        state = state.upsert(managers:[manager])
//
//        let find = state.findBy(id: "123")
//
//        expect(find).notTo(beNil())
//        expect(find?.id).to(equal("123"))
//        expect(find?.username).to(equal("man 123"))
      }
      
      it("update existing") {
//        let manager = CHManager(id: "1",
//          name: "manager 123", avatarUrl: nil,
//          initial: "M 123", color: "#123456",
//          username: "man 123")
//
//        state = state.upsert(managers : [manager])
//
//        let find = state.findBy(id: "1")
//
//        expect(find).notTo(beNil())
//        expect(find?.name).to(equal("manager 123"))
//        expect(find?.username).to(equal("man 123"))
      }
    }
  }
}
