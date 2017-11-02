//
//  SessionsStateTests.swift
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

class SessionsStateTests: QuickSpec {
  override func spec() {
    var sessions: [CHSession]? = nil
    var state = SessionsState()
    
    beforeEach {
      state = SessionsState()
      sessions = [CHSession]()
      for i in 0..<10 {
        
        let session = CHSession(id:"12\(i)", chatType: "UserChat",
                              chatId:"\(i)", personType: "",
                              personId: "", unread:i, alert:0, lastReadAt: nil)
        
        sessions?.append(session)
      }
    }
    
    afterEach {
      sessions = nil;
    }
    
    it("findBy") {
      state = state.upsert(sessions: sessions!)
      let find = state.findBy(userChatId: "0")
      
      expect(find).notTo(beNil())
      expect(find?.id).to(equal("120"))
    }
    
    it("remove") {
      state = state.upsert(sessions: sessions!)
      
      var session = CHSession()
      session.id = "120"
      
      state = state.remove(session: session)
      expect(state.sessions.count).to(equal(9))
    }
    
    describe("upsert") {
      it("normal") {
        state = state.upsert(sessions: sessions!)
        expect(state.sessions.count).to(equal(10))
      }
      
      it("insert new") {
        state = state.upsert(sessions: sessions!)
        
        let session = CHSession(id:"13333", chatType: "UserChat",
                              chatId:"12345", personType: "",
                              personId: "", unread:0, alert:0, lastReadAt: nil)
        
        state = state.upsert(sessions: [session])
        
        let find = state.findBy(userChatId: "12345")
        expect(find).notTo(beNil())
        expect(find!.id).to(equal(session.id))
        expect(state.sessions.count).to(equal(11))
        
        state = state.remove(session: session)
        expect(state.sessions.count).to(equal(10))
      }
      
      it("update existing") {
        state = state.upsert(sessions: sessions!)
        
        let session = CHSession(id:"120", chatType: "UserChat",
                              chatId:"333", personType: "123",
                              personId: "123", unread:0, alert:0, lastReadAt: nil)
        
        state = state.upsert(sessions: [session])
        
        let find = state.findBy(userChatId: "333")
        expect(find).notTo(beNil())
        expect(find!.id).to(equal(session.id))
        expect(find!.chatId).to(equal(session.chatId))
        expect(find!.personId).to(equal(session.personId))
        expect(find!.personType).to(equal(session.personType))
        expect(state.sessions.count).to(equal(10))
      }
    }
  }
}
