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
    
    describe("GetUserChats") {
      context("when its action occurs") {
        it("should insert last messages and update the state properly") {
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
      }
    }

    describe("CreateUserChat") {
      context("when its action occurs") {
        it("should do nothing") {
          var userChat = CHUserChat()
          userChat.id = "123"
          
          state = messagesReducer(action: CreateUserChat(payload:userChat), state: state)
          
          let find = state.findBy(userChatId: "123")
          expect(find.count).to(equal(0))
        }
      }
    }

    describe("GetMessages") {
      context("when its action occurs") {
        it("should insert messages update the state properly") {
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
      }
    }
    
    describe("RemoveMessages") {
      context("when its action occurs") {
        it("should remove messages and update the state properly") {
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
      }
    }

    
    describe("CreateMessage") {
      context("when its action occurs") {
        it("should insert new message and update the state properly") {
          let message = CHMessage(
            chatId: "123",
            message: "message 123",
            type: .Default)

          state = messagesReducer(action: CreateMessage(payload:message), state: state)
          
          let find = state.findBy(userChatId:"123")
          expect(find.count).to(equal(1))
          expect(find.first!.chatId).to(equal(message.chatId))
          expect(find.first!.message).to(equal(message.message))
        }
      }
    }
    
    describe("DeleteMessage") {
      context("when its action occurs") {
        it("should delete the message and update the state properly") {
          let message = CHMessage(
            chatId: "123",
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
      }
    }

    describe("UpdateMessage") {
      context("when its action occurs") {
        it("should update exist message and update the state properly") {
          var message = CHMessage(
            chatId: "123",
            message: "message 123",
            type: .Default)
          
          state = messagesReducer(action: CreateMessage(payload:message), state: state)
          message.message = "123 message"
          
          state = messagesReducer(action: UpdateMessage(payload:message), state: state)
          
          let find = state.findBy(userChatId:"123")
          expect(find.count).to(equal(1))
          expect(find.first!.message).to(equal(message.message))
        }
      }
    }
    
    describe("DeleteUserChat") {
      context("when its action occurs") {
        it("should delete all messages of the chat and update the state properly") {
          let message = CHMessage(
            chatId: "123",
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
      }
    }
    
    describe("InsertWelcome") {
      context("when its action occurs") {
        it("should insert new welcome message and update the state properly") {
          state = messagesReducer(action: InsertWelcome(), state: state)
          
          let find = state.findBy(type: .WelcomeMessage)
          expect(find).notTo(beNil())
        }
      }
    }
    
    describe("GetPush") {
      context("when its action occurs") {
        it("should insert push message and update the state properly") {
          let message = CHMessage(
            chatId: "123",
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
      }
    }
    
    describe("CheckOutSuccess") {
      context("when its action occurs") {
        it("should remove all messages and update the state properly") {
          let message = CHMessage(
            chatId: "123",
            message: "message 123",
            type: .Default)

          state = messagesReducer(action: CreateMessage(payload:message), state: state)
          state = messagesReducer(action: CheckOutSuccess(), state:state)
          
          expect(state.messageDictionary.count).to(equal(0))
        }
      }
    }
    
  }
}
