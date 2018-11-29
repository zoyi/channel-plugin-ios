//
//  SessionsReducer.swift
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

class SessionsReducerTests: QuickSpec {
  override func spec() {
    var state = SessionsState()
    
    beforeEach {
      state = SessionsState()
    }
    
    afterEach {
      
    }
    
    it("GetUserChats") {
//      var sessions = [CHSession]()
//      for i in 0..<10 {
//        let session = CHSession(id:"12\(i)", chatType: "UserChat",
//                              chatId:"\(i)", personType: "",
//                              personId: "", unread:i, alert:0, lastReadAt: nil)
//        
//        sessions.append(session)
//      }
//      
//      let payload = ["sessions" : sessions]
//      state = sessionsReducer(action: GetUserChats(payload: payload), state: state)
//      expect(state.sessions.count).to(equal(10))
    }
    
    it("CreateSession") {
//      let session = CHSession(id:"12", chatType: "UserChat",
//                            chatId:"0", personType: "",
//                            personId: "", unread:0, alert:0, lastReadAt: nil)
//
//      state = sessionsReducer(action: CreateSession(payload: session), state: state)
//
//      let find = state.findBy(userChatId: "0")
//      expect(state.sessions.count).to(equal(1))
//      expect(find).notTo(beNil())
//      expect(find!.id).to(equal(session.id))
    }
    
    it("UpdateSession") {
//      var session = CHSession(id:"12", chatType: "UserChat",
//                            chatId:"0", personType: "",
//                            personId: "", unread:0, alert:0, lastReadAt: nil)
//
//      state = sessionsReducer(
//        action: CreateSession(payload: session), state: state
//      )
//
//      session.unread = 10
//
//      state = sessionsReducer(
//        action: UpdateSession(payload: session), state: state
//      )
//
//      let find = state.findBy(userChatId: "0")
//      expect(state.sessions.count).to(equal(1))
//      expect(find).notTo(beNil())
//      expect(find!.id).to(equal(session.id))
//      expect(find!.unread).to(equal(10))
    }
    
    it("DeleteSession") {
//      let session = CHSession(id:"12", chatType: "UserChat",
//                            chatId:"0", personType: "",
//                            personId: "", unread:0, alert:0, lastReadAt: nil)
//
//      state = sessionsReducer(
//        action: CreateSession(payload: session), state: state
//      )
//
//      var find = state.findBy(userChatId: "0")
//      expect(state.sessions.count).to(equal(1))
//      expect(find).notTo(beNil())
//
//
//      state = sessionsReducer(
//        action: DeleteSession(payload: session), state: state
//      )
//
//      find = state.findBy(userChatId: "0")
//      expect(find).to(beNil())
    }
    
    it("CheckOutSuccess") {
//      let session = CHSession(id:"12", chatType: "UserChat",
//                            chatId:"0", personType: "",
//                            personId: "", unread:0, alert:0, lastReadAt: nil)
//
//      state = sessionsReducer(
//        action: CreateSession(payload: session), state: state
//      )
//
//      var find = state.findBy(userChatId: "0")
//      expect(state.sessions.count).to(equal(1))
//      expect(find).notTo(beNil())
//
//      state = sessionsReducer(action: CheckOutSuccess(), state: state)
//
//      find = state.findBy(userChatId: "0")
//
//      expect(state.sessions.count).to(equal(0))
//      expect(find).to(beNil())
    }
  }
}
