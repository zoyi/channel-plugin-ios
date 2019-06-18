//
//  MessagesStateTests.swift
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

class MessagesStateTests: QuickSpec {
  override func spec() {
    
    var state = MessagesState()
    var messages : [CHMessage]? = nil
    
    beforeEach {
      messages = [CHMessage]()
      for i in 0..<10 {
        let message = CHMessage(chatId: "\(i)",
          message: "message \(i)", type: .Default,
          createdAt: Date.from(year:2010, month:12, day: i+1),
          id: "\(i)")
        
        messages?.append(message)
      }
      
      state = MessagesState()
      state = state.upsert(messages: messages!)
    }
    
    describe("findBy") {
      it("message type") {
        let find = state.findBy(type: .Default)
        
        expect(find).notTo(beNil())
        expect(find?.count).to(equal(10))
      }
      
      it("id") {
        let find = state.findBy(id: "1")
        
        expect(find).notTo(beNil())
        expect(find?.message).to(equal("message 1"))
        expect(find?.chatId).to(equal("1"))
      }
      
      it("userChatId") {
        let find = state.findBy(userChatId: "2")
        
        expect(find).notTo(beNil())
        expect(find.count).to(equal(1))
        expect(find.first!.id).to(equal("2"))
      }
    }
    
    describe("remove") {
      it("by message") {
        let message = CHMessage(chatId: "1",
          message: "message 1", type: .Default,
          createdAt: Date.from(year:2010, month:12, day:1),
          id: "1")
        
        state = state.remove(message: message)
        
        let find = state.findBy(id: "1")
        
        expect(find).to(beNil())
        expect(state.messageDictionary.count).to(equal(9))
      }
      
      it("by type") {
        state = state.remove(type: .Default)
        
        let find = state.findBy(type: .Default)
        
        expect(find?.count).to(equal(0))
      }
     
      it("local messages") {
        let message = CHMessage(
          chatId: "dummy",
          message: "message 1", type: .WelcomeMessage,
          createdAt: Date.from(year:2010, month:12, day: 1),
          id: "111")
        
        state = state.upsert(messages: [message])
        expect(state.messageDictionary.count).to(equal(11))
        
        state = state.removeLocalMessages()
        
        let find = state.findBy(id: "111")
        
        expect(find).to(beNil())
        expect(state.messageDictionary.count).to(equal(10))
      }
      
      it("by userChatId") {
        state = state.remove(userChatId: "1")
        
        let find = state.findBy(userChatId: "1")
        
        expect(find.count).to(equal(0))
        expect(state.messageDictionary.count).to(equal(9))
      }
      
    }
    
    describe("upsert") {
      it("insert new") {
        let message = CHMessage(
          chatId: "dummy",
          message: "message 1", type: .WelcomeMessage,
          createdAt: Date.from(year:2010, month:12, day: 1),
          id: "111")
        
        state = state.upsert(messages: [message])
        expect(state.messageDictionary.count).to(equal(11))
        
        let find = state.findBy(userChatId: "dummy")
        
        expect(find).notTo(beNil())
        expect(find.count).to(equal(1))
        expect(find.first!.chatId).to(equal("dummy"))
      }
      
      it("update existing") {
        let message = CHMessage(
          chatId: "dummy",
          message: "message 1", type: .WelcomeMessage,
          createdAt: Date.from(year:2010, month:12, day: 1),
          id: "1")
        
        state = state.upsert(messages: [message])
        expect(state.messageDictionary.count).to(equal(10))
        
        let find = state.findBy(id: "1")
        
        expect(find).notTo(beNil())
        expect(find?.chatId).to(equal("dummy"))
      }
      
    }
    
    it("insert") {
      let message = CHMessage(
        chatId: "dummy",
        message: "message 1", type: .WelcomeMessage,
        createdAt: Date.from(year:2010, month:12, day: 1),
        id: "1")
      
      state = state.insert(message: message)
      expect(state.messageDictionary.count).to(equal(10))
      
      let find = state.findBy(id: "1")
      
      expect(find).notTo(beNil())
      expect(find?.chatId).to(equal("dummy"))
    }
    
    it("replace") {
      var message = CHMessage(
        chatId: "dummy",
        message: "message 1", type: .WelcomeMessage,
        createdAt: Date.from(year:2010, month:12, day: 1),
        id: "1234")
      
      message.requestId = "1234"
      
      state = state.insert(message: message)
      expect(state.messageDictionary.count).to(equal(11))
      
      var find = state.findBy(id: "1234")
      
      expect(find).notTo(beNil())
      expect(find?.chatId).to(equal("dummy"))
      
      message.message = "replaced"
      state = state.replace(message: message)
      
      find = state.findBy(id: "1234")
      
      expect(find).notTo(beNil())
      expect(find?.message).to(equal("replaced"))
    }
    
  }
}
