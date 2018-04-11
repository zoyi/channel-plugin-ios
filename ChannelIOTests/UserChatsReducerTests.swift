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
    
    it("GetUserChats") {
      userChats = [CHUserChat]()
      for i in 0..<10 {
         let userChat = CHUserChat(
          id: "\(i)0", personType: "", personId: "",
          channelId: "", bindFromId: "", state: "",
          review: "", createdAt: nil, openedAt: nil,
          updatedAt: nil, followedAt: nil, resolvedAt: nil,
          followedBy: "", lastMessageId: "", talkedManagerIds: [],
          resolutionTime: 0, lastMessage: nil, session: nil,
          managers: [], channel: nil)

        userChats?.append(userChat)
      }
      
      let payload:[String:Any] = ["userChats": userChats!, "next":1234 as Int64]
      state = userChatsReducer(action: GetUserChats(payload: payload), state: state)
      expect(state.userChats.count).to(equal(10))
    }
    
    it("CreateUserChat") {
      let userChat = CHUserChat(
        id: "10", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "11", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)
      
      state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
      let find = state.findBy(id: "10")
      expect(state.userChats.count).to(equal(1))
      expect(find).notTo(beNil())
      expect(find!.id).to(equal("10"))
    }
    
    it("UpdateUserChat") {
      var userChat = CHUserChat(
        id: "10", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "11", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)

      state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
      
      let now = Date()
      userChat.lastMessageId = "12"
      userChat.updatedAt = now
      
      state = userChatsReducer(action: UpdateUserChat(payload:userChat), state: state)
      
      let find = state.findBy(id: "10")
      expect(state.userChats.count).to(equal(1))
      expect(find).notTo(beNil())
      expect(find!.id).to(equal("10"))
      expect(find!.lastMessageId).to(equal("12"))
      expect(find!.updatedAt).to(equal(now))
    }
    
    it("DeleteUserChat") {
      let userChat = CHUserChat(
        id: "10", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "11", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)
      
      state = userChatsReducer(action: CreateUserChat(payload:userChat), state: state)
      state = userChatsReducer(action: DeleteUserChat(payload:userChat.id), state: state)
      
      let find = state.findBy(id: "10")
      
      expect(state.userChats.count).to(equal(0))
      expect(find).to(beNil())
    }
    
    it("JoinedUserChat") {      
      state = userChatsReducer(action: JoinedUserChat(payload: "10"), state: state)
      expect(state.currentUserChatId).to(equal("10"))
    }
    
    it("LeavedUserChat") {
      state = userChatsReducer(action: JoinedUserChat(payload: "10"), state: state)
      expect(state.currentUserChatId).to(equal("10"))
      state = userChatsReducer(action: LeavedUserChat(payload: "10"), state: state)
      expect(state.currentUserChatId).to(equal(""))
    }
    
    it("GetPush") {
      let userChat = CHUserChat(
        id: "10", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "11", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)
      
      var push = CHPush()
      push.userChat = userChat
      
      state = userChatsReducer(action: GetPush(payload:push), state: state)
      
      let find = state.findBy(id: "10")
      expect(state.userChats.count).to(equal(1))
      expect(find).notTo(beNil())
      expect(find!.id).to(equal("10"))
    }
    
    it("CheckOutSuccess") {
      let userChat = CHUserChat(
        id: "10", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "11", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)
      
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
