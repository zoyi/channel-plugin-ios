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
      for i in 0..<10 {
        let manager = CHManager(
          id: "\(i)", name: "manager \(i)",
          avatarUrl: nil, initial: "M \(i)",
          color: "#123456", username: "hello \(i)",
          desc: "", online: false)
        
        managers?.append(manager)
      }
      
      state = ManagersState()
      state = state.upsert(managers: managers!)
    }

    describe("findBy") {
      context("when it is used to find managers"){
        it("should return correct manager") {
          let find = state.findBy(id: "1")
          
          expect(find).notTo(beNil())
          expect(find?.initial).to(equal("M 1"))
          expect(find?.username).to(equal("hello 1"))
        }
        
        it("should also return correct managers") {
          let find = state.findBy(ids: ["1", "2"]).sorted { $0.id < $1.id }
          
          expect(find).notTo(beNil())
          expect(find.count).to(equal(2))
          expect(find[0].name).to(equal("manager 1"))
          expect(find[1].name).to(equal("manager 2"))
        }
      }
    }
    
    describe("remove") {
      context("when it is used to remove manager") {
        it("should properly update state") {
          state = state.remove(managerId: "1")
          
          let find = state.findBy(id: "1")
          
          expect(find).to(beNil())
          expect(state.managerDictionary.count).to(equal(9))
        }
      }
    }
    
    describe("upsert") {
      context("when it is used to upsert manager") {
        it("should update state properly") {
          let i = 1234
          let manager = CHManager(
            id: "\(i)", name: "manager \(i)",
            avatarUrl: nil, initial: "M \(i)",
            color: "#123456", username: "hello \(i)",
            desc: "", online: false)

          state = state.upsert(managers:[manager])

          let find = state.findBy(id: "1234")

          expect(find).notTo(beNil())
          expect(find?.id).to(equal("1234"))
          expect(find?.username).to(equal("hello 1234"))
        }
        
        it("should update exist manager properly") {
          let i = 1
          let manager = CHManager(
            id: "\(i)", name: "manager 123",
            avatarUrl: nil, initial: "M \(i)",
            color: "#123456", username: "hello 123",
            desc: "", online: false)

          state = state.upsert(managers : [manager])

          let find = state.findBy(id: "1")

          expect(find).notTo(beNil())
          expect(find?.name).to(equal("manager 123"))
          expect(find?.username).to(equal("hello 123"))
        }
      }
    }
  }
}
