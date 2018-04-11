//
//  MessagesReducer.swift
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

class MessagesReducerTests: QuickSpec {
  override func spec() {
    
    var state = MessagesState()
    var messages : [CHMessage]? = nil
    
    beforeEach {
      state = MessagesState()
      messages = nil
    }
    
    it("GetUserChats") {
      messages = [CHMessage]()
      for i in 0..<10 {
        let message = CHMessage(chatId: "\(i)",
          message: "message \(i)", type: .Default,
          createdAt: Date.from(year:2010, month:12, day: i+1))
        
        messages?.append(message)
      }
      
      let payload = ["messages": messages!]
      state = messagesReducer(action: GetUserChats(payload: payload), state: state)
      
      expect(state.messageDictionary.count).to(equal(10))
    }
    
    it("CreateUserChat") {
      var userChat = CHUserChat()
      userChat.id = "123"
      
      state = messagesReducer(action: CreateUserChat(payload:userChat), state: state)
      
      let find = state.findBy(userChatId: "123")
      expect(find.count).to(equal(0))
    }
    
    it("GetMessages") {
      messages = [CHMessage]()
      for i in 0..<10 {
        let message = CHMessage(chatId: "\(i)\(i)",
          message: "message \(i)", type: .Default,
          createdAt: Date.from(year:2010, month:12, day: i+1))
        
        messages?.append(message)
      }
      
      let payload = ["messages" : messages!]
      state = messagesReducer(action: GetMessages(payload:payload), state: state)
      
      expect(state.messageDictionary.count).to(equal(10))
    }
    
    it("RemoveMessages") {
      messages = [CHMessage]()
      for i in 0..<10 {
        let message = CHMessage(chatId: "\(i)\(i)",
          message: "message \(i)", type: .Default,
          createdAt: Date.from(year:2010, month:12, day: i+1))
        
        messages?.append(message)
      }
      
      let payload = ["messages": messages!]
      state = messagesReducer(action: GetUserChats(payload: payload), state: state)
      state = messagesReducer(action: RemoveMessages(payload: "11"), state: state)
      
      let find = state.findBy(userChatId: "11")
      expect(state.messageDictionary.count).to(equal(9))
      expect(find.count).to(equal(0))
    }
    
    it("CreateMessage") {
      let message = CHMessage(chatId: "123",
                            message: "message 123",
                            type: .Default)
      
      state = messagesReducer(action: CreateMessage(payload:message), state: state)
      
      let find = state.findBy(userChatId:"123")
      expect(find.count).to(equal(1))
      expect(find.first!.chatId).to(equal(message.chatId))
      expect(find.first!.message).to(equal(message.message))
    }
    
    it("DeleteMessage") {
      let message = CHMessage(chatId: "123",
                            message: "message 123",
                            type: .Default)
      
      state = messagesReducer(action: CreateMessage(payload:message), state: state)
      
      var find = state.findBy(userChatId:"123")
      expect(state.messageDictionary.count).to(equal(1))
      expect(find).notTo(beNil())
      
      state = messagesReducer(action: DeleteMessage(payload:message), state: state)
      
      find = state.findBy(userChatId:"123")
      expect(find.count).to(equal(0))
    }
    
    it("UpdateMessage") {
      var message = CHMessage(chatId: "123",
                            message: "message 123",
                            type: .Default)
      
      state = messagesReducer(action: CreateMessage(payload:message), state: state)
      message.message = "123 message"
      
      state = messagesReducer(action: UpdateMessage(payload:message), state: state)
      
      let find = state.findBy(userChatId:"123")
      expect(find.count).to(equal(1))
      expect(find.first!.message).to(equal(message.message))
    }
    
    it("DeleteUserChat") {
      let message = CHMessage(chatId: "123",
                            message: "message 123",
                            type: .Default)
      
      state = messagesReducer(
        action: CreateMessage(payload:message), state: state
      )
      
      var find = state.findBy(userChatId:"123")
      expect(state.messageDictionary.count).to(equal(1))
      
      state = messagesReducer(
        action: DeleteMessage(payload:message), state: state
      )
      
      find = state.findBy(userChatId:"123")
      expect(find.count).to(equal(0))
    }
    
    it("CreateChannelClosed") {
      state = messagesReducer(
        action: CreateChannelClosed(), state: state
      )
      
      let find = state.findBy(type: .ChannelClosed)
      expect(find).notTo(beNil())
      expect(find?.first!.messageType).to(equal(MessageType.ChannelClosed))
    }
    
    it("ClickBusinessHour") {
      var userChat = CHUserChat()
      userChat.id = "123"
      
      state = messagesReducer(
        action: ClickBusinessHour(payload: userChat), state: state
      )
      
      let find = state.findBy(type: .BusinessHourQuestion)
      expect(find).notTo(beNil())
    }
    
    it("AnswerBusinessHour") {
      var userChat = CHUserChat()
      userChat.id = "123"
      
      state = messagesReducer(
        action: AnswerBusinessHour(payload: userChat), state: state
      )
      
      let find = state.findBy(type: .BusinessHourAnswer)
      expect(find).notTo(beNil())
    }
    
    it("InsertWelcome") {
      state = messagesReducer(
        action: InsertWelcome(), state: state
      )
      
      let find = state.findBy(type: .WelcomeMessage)
      expect(find).notTo(beNil())
    }
    
    it("GetPush") {
      let message = CHMessage(chatId: "123",
                            message: "push message",
                            type: .Default)
      var push = CHPush()
      push.message = message
      
      state = messagesReducer(action: GetPush(payload: push), state: state)
      
      let msgArray = state.findBy(userChatId: "123")
      let msg = msgArray.first
      
      expect(msgArray.count).to(equal(1))
      expect(msg?.chatId).to(equal(message.chatId))
    }
    
    it("CheckOutSuccess") {
      let message = CHMessage(chatId: "123",
                            message: "message 123",
                            type: .Default)
      
      state = messagesReducer(action: CreateMessage(payload:message), state: state)
      state = messagesReducer(action: CheckOutSuccess(), state:state)
      
      expect(state.messageDictionary.count).to(equal(0))
    }
    
  }
}
