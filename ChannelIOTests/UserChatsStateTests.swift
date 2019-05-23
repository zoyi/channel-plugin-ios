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
      state = UserChatsState()
      userChats = [CHUserChat]()
      for i in 0..<10 {
          let userChat = CHUserChat(
            id: "\(i)0", personType: "", personId: "", channelId: "",
            state: .open, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            followedBy: "", hostId: nil, hostType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil,
            lastTalkedHost: nil, channel: nil, hasRemoved: false)
        userChats?.append(userChat)
      }
      
      state = state.upsert(userChats:userChats!)
    }
    
    afterEach {
      userChats = nil
    }
    
    describe("findBy") {
      context("when it is used to find user chat by id") {
        it("should return userchat properly") {
          let find = state.findBy(id: "10")
          
          expect(find).notTo(beNil())
          expect(find?.id).to(equal("10"))
        }
      }
      
      context("when it is used to find not exist user chat by id") {
        it("should return nil") {
          let find = state.findBy(id: "123")
          expect(find).to(beNil())
        }
      }
      
      context("when it is used to find multiple userchats by id") {
        it("should return correct number of manangers") {
          let find = state.findBy(ids: ["10","20"])
          
          expect(find).notTo(beNil())
          expect(find.count).to(equal(2))
          expect(find.contains{ $0.id == "10"}).to(equal(true))
          expect(find.contains{ $0.id == "20"}).to(equal(true))
        }
      }
    }
    
    describe("remove") {
      context("when it is used to remove user chat by id") {
        it("should remove given chat and update the state") {
          state = state.remove(userChatId: "10")
          
          let find = state.findBy(id:"10")
          
          expect(find).notTo(beNil())
          expect(find?.hasRemoved).to(equal(true))
        }
      }

      context("when it is used to remove multiple userchat") {
        it("userChatIds") {
          state = state.remove(userChatIds: ["10", "20"])
          
          let find = state.findBy(ids: ["10","20"]).sorted { $0.id < $1.id }
          
          expect(find.count).to(equal(2))
          expect(state.userChats.count).to(equal(10))
          expect(find[0].hasRemoved).to(equal(true))
          expect(find[1].hasRemoved).to(equal(true))
        }
      }
    }
    
    describe("upsert") {
      context("when it is used to insert valid user chat") {
        it("should update the state properly") {
          var userChat = CHUserChat()
          userChat.id = "1234"
          
          state = state.upsert(userChats: [userChat])
          
          let find = state.findBy(id:"1234")
          
          expect(find).notTo(beNil())
          expect(find?.id).to(equal("1234"))
        }
      }
      
      context("when it is used to update existing user chat") {
        it("should update the state properly") {
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
}
