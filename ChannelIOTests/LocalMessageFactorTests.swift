//
//  LocalMessageFactorTests.swift
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

class LocalMessageFactoryTests: QuickSpec {
  override func spec() {
    it("channel close") {
      let messages = LocalMessageFactory.generate(type: .ChannelClosed)
      expect(messages.count).to(equal(1))
      
      let closemsg = messages.first!
      expect(closemsg.chatId).to(equal("dummy"))
      expect(closemsg.messageType).to(equal(MessageType.ChannelClosed))
      expect(closemsg.id).to(equal("close_dummy"))
    }
    
    it("auto business hour question") {
      let messages = LocalMessageFactory.generate(type: .BusinessHourQuestion)
      expect(messages.count).to(equal(1))
      
      let msg = messages.first!
      expect(msg.chatId).to(equal(CHConstants.dummy))
      expect(msg.id).to(equal("bhq_dummy"))
      expect(msg.messageType).to(equal(MessageType.BusinessHourQuestion))
    }
    
    it("auto business hour answer") {
      let messages = LocalMessageFactory.generate(type: .BusinessHourAnswer)
      expect(messages.count).to(equal(1))
      
      let msg = messages.first!
      expect(msg.chatId).to(equal(CHConstants.dummy))
      expect(msg.id).to(equal("bha_dummy"))
      expect(msg.messageType).to(equal(MessageType.BusinessHourAnswer))
      //expect(msg.message).to(equal(""))
    }
    
    it("date divider") {
      //manually separate dates
      var dates = [Date]()
      for i in 0..<5 {
        dates.append(Date.from(year: 2012, month: 12, day: i))
      }
      
      var messages = [CHMessage]()
      
      for i in 0..<5 {
        let message = CHMessage(chatId: "123",
                              message: "test",
                              type: .Default,
                              createdAt: dates[i])
        messages.append(message)
      }
      
      let modifiedMessages = LocalMessageFactory
        .generate(type: .DateDivider, messages: messages)
      
      var dividerCount = 0
      expect(modifiedMessages.count).to(equal(10))
      
      for msg in modifiedMessages {
        if msg.messageType == .DateDivider {
          dividerCount += 1
        }
      }
      
      expect(dividerCount).to(equal(5))
    }
    
    it("new alert message") {
      var userChat = CHUserChat()
      var session = CHSession()
      session.unread = 4
      userChat.session = session
      
      let message = CHMessage(chatId: "31231", message: "test", type: .Default)
      let messages = [ message, message, message, message, message, message]
      let modifiedMessages = LocalMessageFactory
        .generate(type: .NewAlertMessage, messages: messages, userChat: userChat)
      
      let alertmsg = modifiedMessages[2]
      expect(alertmsg.messageType).to(equal(MessageType.NewAlertMessage))
    }
    
    describe("user message") {
      
      it("without user chat") {
        let messages = LocalMessageFactory.generate(type: .UserMessage)
        expect(messages.count).to(equal(1))
      
        let closemsg = messages.first!
        expect(closemsg.chatId).to(equal("dummy"))
        expect(closemsg.message).to(equal(""))
        expect(closemsg.messageType).to(equal(MessageType.UserMessage))
      }
      
      it("with userChat and text") {
        var userChat = CHUserChat()
        userChat.id = "12345"
        let messages = LocalMessageFactory.generate(type: .UserMessage,
                                                    messages: [],
                                                    userChat: userChat,
                                                    text: "WHAHAHAH")
        
        expect(messages.count).to(equal(1))
        
        let closemsg = messages.first!
        expect(closemsg.chatId).to(equal("12345"))
        expect(closemsg.message).to(equal("WHAHAHAH"))
        expect(closemsg.messageType).to(equal(MessageType.UserMessage))
      }
    }
    
    it("user info dialog") {
      var userChat = CHUserChat()
      userChat.id = "12345"
      
      let messages = LocalMessageFactory
        .generate(type: .UserInfoDialog, messages: [], userChat: userChat)
      expect(messages.count).to(equal(1))
      
      let msg = messages.first!
      expect(msg.messageType).to(equal(MessageType.UserInfoDialog))
      expect(msg.message).to(equal(""))
    }
    
    it("welcome message") {
      let messages = LocalMessageFactory.generate(type: .WelcomeMessage)
      expect(messages.count).to(equal(1))
      
      let closemsg = messages.first!
      expect(closemsg.chatId).to(equal("dummy"))
      expect(closemsg.messageType).to(equal(MessageType.WelcomeMessage))
      expect(closemsg.id).to(equal("dummy"))
    }
  }
}
