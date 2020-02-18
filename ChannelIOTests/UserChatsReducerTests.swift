//
//  UserChatsReducer.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
//import RxSwpift
//import ReSwift

@testable import ChannelIO

class UserChatsReducerTests: QuickSpec {
  override func spec() {
    var state = UserChatsState()
    var userChats: [CHUserChat]? = nil
    
    beforeEach {
      state = UserChatsState()
    }
    
    afterEach {
      userChats = nil
    }
    
    describe("GetUserChats") {
      context("when its action occurs") {
        it("should insert chats and update the state") {
          userChats = [CHUserChat]()
          for i in 0..<10 {
            let userChat = CHUserChat(
              id: "\(i)0", personType: .manager, personId: "", channelId: "",
              state: .unassigned, review: "", createdAt: nil, openedAt: nil,
              updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
              assigneeId: nil, assigneeType: nil, appMessageId: nil,
              resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
              hasRemoved: false)
            
            userChats?.append(userChat)
          }
          
          let payload:[String:Any] = ["userChats": userChats!, "next":"1234"]
          state = userChatsReducer(action: GetUserChats(payload: payload), state: state)
          expect(state.userChats.count).to(equal(10))
        }
      }
    }

    describe("CreateUserChat") {
      context("when its action occurs") {
        it("should insert a new chat and update the state") {

          let userChat = CHUserChat(
            id: "10", personType: .manager, personId: "", channelId: "",
            state: .unassigned, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            assigneeId: nil, assigneeType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
            hasRemoved: false)
          
          state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
          let find = state.findBy(id: "10")
          expect(state.userChats.count).to(equal(1))
          expect(find).notTo(beNil())
          expect(find!.id).to(equal("10"))
        }
      }
    }
    
    describe("UpdateUserChat") {
      context("when its action occurs") {
        it("should update existing chat and update the state accordingly") {
          var userChat = CHUserChat(
            id: "10", personType: .manager, personId: "", channelId: "",
            state: .unassigned, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            assigneeId: nil, assigneeType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
            hasRemoved: false)
          
          state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
          
          let now = Date()
          userChat.updatedAt = now
          
          state = userChatsReducer(action: UpdateUserChat(payload:userChat), state: state)
          
          let find = state.findBy(id: "10")
          expect(state.userChats.count).to(equal(1))
          expect(find).notTo(beNil())
          expect(find!.id).to(equal("10"))
          
          expect(find!.updatedAt).to(equal(now))
        }
      }
    }
    
    describe("DeleteUserChat") {
      context("when its action occurs") {
        it("should mark the chat as delete and update the state") {
          let userChat = CHUserChat(
            id: "10", personType: .manager, personId: "", channelId: "",
            state: .unassigned, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            assigneeId: nil, assigneeType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
            hasRemoved: false)
          
          state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
          state = userChatsReducer(action: DeleteUserChat(payload:userChat), state: state)
          
          let find = state.findBy(id: "10")
          
          expect(state.userChats.count).to(equal(1))
          expect(find).notTo(beNil())
          expect(find?.hasRemoved).to(equal(true))
        }
      }
    }
    
    describe("JoinedUserChat") {
      context("when its action occurs") {
        it("should update state's currentUserChatId properly") {
          state = userChatsReducer(action: JoinedUserChat(payload: "10"), state: state)
          expect(state.currentUserChatId).to(equal("10"))
        }
      }
    }
    
    describe("LeavedUserChat") {
      context("when its action occurs") {
        it("should update state's currentUserChatId to default") {
          state = userChatsReducer(action: JoinedUserChat(payload: "10"), state: state)
          expect(state.currentUserChatId).to(equal("10"))
          state = userChatsReducer(action: LeavedUserChat(payload: "10"), state: state)
          expect(state.currentUserChatId).to(equal(""))
        }
      }
    }
    
    describe("GetPush") {
      context("when its action occurs") {
        it("should upsert the chat and update the state") {
          let userChat = CHUserChat(
            id: "10", personType: .manager, personId: "", channelId: "",
            state: .unassigned, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            assigneeId: nil, assigneeType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
            hasRemoved: false)
          
          var push = CHPush()
          push.userChat = userChat
          
          state = userChatsReducer(action: GetPush(payload:push), state: state)
          
          let find = state.findBy(id: "10")
          expect(state.userChats.count).to(equal(1))
          expect(find).notTo(beNil())
          expect(find!.id).to(equal("10"))
        }
      }
    }
    
    describe("CheckOutSuccess") {
      context("when its action occurs") {
        it("should remove all chats and update the state") {
          let userChat = CHUserChat(
            id: "10", personType: .manager, personId: "", channelId: "",
            state: .unassigned, review: "", createdAt: nil, openedAt: nil,
            updatedAt: nil, followedAt: nil, resolvedAt: nil, closedAt: nil,
            assigneeId: nil, assigneeType: nil, appMessageId: nil,
            resolutionTime: 0, lastMessage: nil, session: nil, channel: nil,
            hasRemoved: false)
          
          state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
          
          var find = state.findBy(id: "10")
          expect(state.userChats.count).to(equal(1))
          expect(find).notTo(beNil())
          expect(find!.id).to(equal("10"))
          
          state = userChatsReducer(action: CheckOutSuccess(), state: state)
          
          find = state.findBy(id: "10")
          expect(state.userChats.count).to(equal(0))
          expect(find).to(beNil())
        }
      }
    }
  }
}
