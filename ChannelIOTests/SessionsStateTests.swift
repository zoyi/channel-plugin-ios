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

@testable import ChannelIO

class SessionsStateTests: QuickSpec {
  override func spec() {
    var sessions: [CHSession]? = nil
    var state = SessionsState()
    
    beforeEach {
      state = SessionsState()
      sessions = [CHSession]()
      for i in 0..<10 {
        let session = CHSession(
          id: "12\(i)", chatType: "UserChat", chatId: "\(i)",
          personType: "", personId: "", unread: i,
          alert: 0, readAt: nil, postedAt: nil)

        sessions?.append(session)
      }
    }
    
    afterEach {
      sessions = nil;
    }
    
    describe("findBy") {
      context("when it is used to find a session by userChat id") {
        it("should return existing session") {
          state = state.upsert(sessions: sessions!)
          let find = state.findBy(userChatId: "0")
          
          expect(find).notTo(beNil())
          expect(find?.id).to(equal("120"))
        }
      }
      
      context("when it is used to find a session by nnot existing userChat id") {
        it("should return nil") {
          state = state.upsert(sessions: sessions!)
          let find = state.findBy(userChatId: "1234")
          
          expect(find).to(beNil())
        }
      }
    }

    describe("remove") {
      context("when it is used to remove a session") {
        it("should update the state properly") {
          state = state.upsert(sessions: sessions!)
          
          var session = CHSession()
          session.id = "120"
          
          state = state.remove(session: session)
          expect(state.sessions.count).to(equal(9))
        }
      }
    }
    
    describe("upsert") {
      context("when it is used to insert new sessions") {
        it("should update the state properly") {
          state = state.upsert(sessions: sessions!)
          expect(state.sessions.count).to(equal(10))
        }
        
        it("insert new") {
          state = state.upsert(sessions: sessions!)
          let i = 12345
          let session = CHSession(
            id: "12\(i)", chatType: "UserChat", chatId: "\(i)",
            personType: "", personId: "", unread: i,
            alert: 0, readAt: nil, postedAt: nil)
          
          state = state.upsert(sessions: [session])
          
          let find = state.findBy(userChatId: "12345")
          expect(find).notTo(beNil())
          expect(find!.id).to(equal(session.id))
          expect(state.sessions.count).to(equal(11))
          
          state = state.remove(session: session)
          expect(state.sessions.count).to(equal(10))
        }
      }
      
      context("when it is used to update existing session") {
        it("should update the session properly") {
          state = state.upsert(sessions: sessions!)
          let i = 0
          let session = CHSession(
            id: "12\(i)", chatType: "UserChat", chatId: "333",
            personType: "User", personId: "123", unread: i,
            alert: 0, readAt: nil, postedAt: nil)
          
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
}
