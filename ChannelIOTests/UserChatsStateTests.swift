//
//  UserChatsStateTests.swift
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

class UserChatsStateTests: QuickSpec {
  override func spec() {
    var state = UserChatsState()
    var userChats: [CHUserChat]? = nil
    
    beforeEach {
//      state = UserChatsState()
//      userChats = [CHUserChat]()
//      for i in 0..<10 {
//        let userChat = CHUserChat(
//          id: "\(i)0", personType: "", personId: "",
//          channelId: "", bindFromId: "", state: "",
//          review: "", createdAt: nil, openedAt: nil,
//          updatedAt: nil, followedAt: nil, resolvedAt: nil,
//          followedBy: "", lastMessageId: "1\(i)1", talkedManagerIds: [],
//          resolutionTime: 0, lastMessage: nil, session: nil,
//          managers: [], channel: nil)
//        
//        userChats?.append(userChat)
//      }
//      
//      state = state.upsert(userChats:userChats!)
    }
    
    afterEach {
      userChats = nil
    }
    
    describe("findBy") {
      context("id") {
        it("normal") {
          let find = state.findBy(id: "10")
          
          expect(find).notTo(beNil())
          expect(find?.id).to(equal("10"))
        }
        
        it("not found") {
          let find = state.findBy(id: "123")
          
          expect(find).to(beNil())
        }
      }
      
      it("ids") {
        let find = state.findBy(ids: ["10","20"])
        
        expect(find).notTo(beNil())
        expect(find.count).to(equal(2))
      }
      
    }
    
    describe("remove") {
      
      it("userChatId") {
        state = state.remove(userChatId: "10")
        
        let find = state.findBy(id:"10")
        
        expect(find).to(beNil())
        expect(state.userChats.count).to(equal(9))
      }
      
      it("userChatIds") {
        state = state.remove(userChatIds: ["10", "20"])
        
        let find = state.findBy(ids: ["10","20"])
        
        expect(find.count).to(equal(0))
        expect(state.userChats.count).to(equal(8))
      }
      
    }
    
    describe("upsert") {
      
      it("normal") {
        var userChat = CHUserChat()
        userChat.id = "1234"
        
        state = state.upsert(userChats: [userChat])
        
        let find = state.findBy(id:"1234")
        
        expect(find).notTo(beNil())
        expect(find?.id).to(equal("1234"))
      }
      
      it("update existing") {
        let now = Date()
        var userChat = CHUserChat()
        userChat.id = "10"
        userChat.updatedAt = now
        
        state = state.upsert(userChats: [userChat])
        
        let find = state.findBy(id:"10")
        
        expect(find).notTo(beNil())
        expect(find?.updatedAt).to(equal(now))
        expect(state.userChats.count).to(equal(10))
      }
    }
  }
}
