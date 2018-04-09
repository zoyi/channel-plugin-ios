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

@testable import CHPlugin

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
    
    it("GetUserChats") {
      managers = [CHManager]()
      for i in 0..<10 {
        let manager = CHManager(id: "\(i)",
          name: "manager \(i)", avatarUrl: nil,
          initial: "M \(i)", color: "#123456",
          username: "man \(i)")
        
        managers?.append(manager)
      }
      
      let payload = ["managers":managers!]
      state = managersReducer(action: GetUserChats(payload:payload), state: state)
      expect(state.managerDictionary.count).to(equal(10))
    }
    
    it("UpdateManager") {
      managers = [CHManager]()
      for i in 0..<10 {
        let manager = CHManager(id: "\(i)",
          name: "manager \(i)", avatarUrl: nil,
          initial: "M \(i)", color: "#123456",
          username: "man \(i)")
        
        managers?.append(manager)
      }
      
      let payload = ["managers":managers!]
      state = managersReducer(action: GetUserChats(payload:payload), state: state)
      
      let manager = CHManager(id: "0",
        name: "manager 111", avatarUrl: nil,
        initial: "M 111", color: "#654321",
        username: "man 111")
      
      state = managersReducer(action: UpdateManager(payload:manager), state: state)
      
      let find = state.findBy(id: "0")
      
      expect(find).notTo(beNil())
      expect(find!.name).to(equal(manager.name))
      expect(find!.initial).to(equal(manager.initial))
      expect(find!.username).to(equal(manager.username))
    }
    
    it("GetPush") {
      let manager = CHManager(id: "0",
                    name: "manager 111", avatarUrl: nil,
                    initial: "M 111", color: "#654321",
                    username: "man 111")
      
      var push = CHPush()
      push.manager = manager
      
      state = managersReducer(action: GetPush(payload:push), state: state)
      
      let find = state.findBy(id: "0")
      
      expect(find).notTo(beNil())
      expect(find!.name).to(equal(manager.name))
      expect(find!.initial).to(equal(manager.initial))
      expect(find!.username).to(equal(manager.username))
    }
    
    it("CheckOutSuccess") {
      let manager = CHManager(id: "0",
                            name: "manager 111", avatarUrl: nil,
                            initial: "M 111", color: "#654321",
                            username: "man 111")
      
      var push = CHPush()
      push.manager = manager
      
      state = managersReducer(action: GetPush(payload:push), state: state)
      state = managersReducer(action: CheckOutSuccess(), state: state)
      
      let find = state.findBy(id: "0")
      
      expect(find).to(beNil())
    }
    
  }
}
