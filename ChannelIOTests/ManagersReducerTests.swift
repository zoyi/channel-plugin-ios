//
//  ManagersReducer.swift
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

class ManagersReducerTests: QuickSpec {
  
  override func spec() {
    
    var state = ManagersState()
    var managers : [CHManager]? = nil
    
    beforeEach {
      state = ManagersState()
      managers = nil
    }
    
    afterEach {
      
    }
    
    describe("GetUserChats") {
      context("when its action occurs") {
        it("should upsert managers and update the state") {
          managers = [CHManager]()
          for i in 0..<10 {
            let manager = CHManager(
              id: "\(i)", name: "manager \(i)",
              avatarUrl: nil, initial: "M \(i)",
              color: "#123456", username: "hello \(i)",
              desc: "", online: false)
            
            managers?.append(manager)
          }
          
          let payload = ["managers":managers!]
          state = managersReducer(action: GetUserChats(payload:payload), state: state)
          expect(state.managerDictionary.count).to(equal(10))
        }
      }
    }
    
    describe("UpdateManager") {
      context("when its action occurs") {
        it("should update existing manager and update the state") {
          managers = [CHManager]()
          for i in 0..<10 {
            let manager = CHManager(
              id: "\(i)", name: "manager \(i)",
              avatarUrl: nil, initial: "M \(i)",
              color: "#123456", username: "hello \(i)",
              desc: "", online: false)
            
            managers?.append(manager)
          }
          
          let payload = ["managers":managers!]
          state = managersReducer(action: GetUserChats(payload:payload), state: state)
          
          let manager = CHManager(
            id: "0", name: "manager 111",
            avatarUrl: nil, initial: "M 111",
            color: "#123456", username: "hello 111",
            desc: "", online: false)
          
          state = managersReducer(action: UpdateManager(payload:manager), state: state)
          
          let find = state.findBy(id: "0")
          
          expect(find).notTo(beNil())
          expect(find!.name).to(equal(manager.name))
          expect(find!.initial).to(equal(manager.initial))
          expect(find!.username).to(equal(manager.username))
        }
      }
    }
    
    describe("GetPush") {
      context("when its action occurs") {
        it("should upsert the manager and update the state") {
          let manager = CHManager(
            id: "0", name: "manager 111",
            avatarUrl: nil, initial: "M 111",
            color: "#123456", username: "hello 111",
            desc: "", online: false)
          
          var push = CHPush()
          push.manager = manager
          
          state = managersReducer(action: GetPush(payload:push), state: state)
          
          let find = state.findBy(id: "0")
          
          expect(find).notTo(beNil())
          expect(find!.name).to(equal(manager.name))
          expect(find!.initial).to(equal(manager.initial))
          expect(find!.username).to(equal(manager.username))
        }
        
      }
    }
    
    describe("CheckOutSuccess") {
      context("when its action occurs") {
        it("should remove all managers and update the state") {
          let manager = CHManager(
            id: "0", name: "manager 111",
            avatarUrl: nil, initial: "M 111",
            color: "#123456", username: "hello 111",
            desc: "", online: false)
          
          var push = CHPush()
          push.manager = manager
          
          state = managersReducer(action: GetPush(payload:push), state: state)
          state = managersReducer(action: CheckOutSuccess(), state: state)
          
          let find = state.findBy(id: "0")
          
          expect(find).to(beNil())
        }
      }
    }
  }
}
