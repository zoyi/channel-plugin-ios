//
//  MessageTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
@testable import CHPlugin

class MessageTests: QuickSpec {
  
  let userChatId = "31482"
  let testMessage = "test message"
  
  override func spec() {
    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "7")
      PrefStore.setCurrentUserId(userId: "214")
    }
    
    describe("create") {
      it("default") {
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default)
        expect(message.requestId).notTo(equal(""))
        expect(message.id).to(equal(message.requestId))
        expect(message.entity).to(beNil())
        expect(message.file).to(beNil())
        expect(message.webPage).to(beNil())
        expect(message.log).to(beNil())
      }
      
      it("normal") {
        let user = CHUser(
          id:"77", name:"Joyy", avatarUrl:nil,
          initial:"J", color:"#123456",
          ghost:false, mobileNumber: nil, meta:nil)
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          entity: user)

        expect(message.requestId).notTo(equal(""))
        expect(message.id).to(equal(message.requestId))
        expect(message.entity).notTo(beNil())
        expect(message.personId).to(equal(user.id))
        expect(message.personType).to(equal("User"))
        expect(message.messageType).to(equal(MessageType.Default))
      }
    }
    
    describe("compares") {
      
      let user = CHUser(
        id:"77", name:"Joyy", avatarUrl:nil,
        initial:"J", color:"#123456",
        ghost:false, mobileNumber: nil, meta:nil)

      let message = CHMessage(
        chatId: self.userChatId,
        message: self.testMessage,
        type: .Default,
        entity: user,
        createdAt: Date())
      
      let messagetwo = CHMessage(
        chatId: self.userChatId,
        message: self.testMessage,
        type: .Default,
        entity: user,
        createdAt: Date())
      
      let otherUser = CHUser(
        id:"75", name:"Joyy2", avatarUrl:nil,
        initial:"P", color:"#123456",
        ghost:false, mobileNumber: nil, meta:nil)

      let otherMessage = CHMessage(
        chatId: self.userChatId,
        message: self.testMessage,
        type: .Default,
        entity: otherUser,
        createdAt: Date())

      context("is coutinuous") {
        it("same person close time") {
          let continuous = message.isContinue(previous: messagetwo)
          expect(continuous).to(beTrue())
        }
        
        it("same person separate time") {
          var temp = messagetwo
          temp.createdAt = Date(timeInterval: 10000000, since: message.createdAt)
          let continuous = message.isContinue(previous: temp)
          expect(continuous).notTo(beTrue())
        }
        
        it("diff person close time") {
          let continuous = message.isContinue(previous: otherMessage)
          expect(continuous).notTo(beTrue())
        }
        
        it("diff person separate time") {
          var temp = otherMessage
          temp.createdAt = Date(timeInterval: 10000000, since: message.createdAt)
          let continuous = message.isContinue(previous: temp)
          expect(continuous).notTo(beTrue())
        }
      }
      
      context("is same date") {
        it("normal") {
          let same = message.isSameDate(previous: otherMessage)
          expect(same).to(beTrue())
        }
        
        it("should not same date") {
          var tempmsg = messagetwo
          tempmsg.createdAt = Date(timeInterval: 10000000, since: message.createdAt)
          let same = message.isSameDate(previous: tempmsg)
          expect(same).to(beFalse())
        }
      }
    }
    
    describe("sending") {
      
      it("normal text") {
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default)
        waitUntil (timeout: 10) { done in
          _ = message.send().subscribe(onNext: { (msg) in
            expect(msg.chatId).to(equal(message.chatId))
            expect(msg.message).to(equal(message.message))
            done()
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        }
      }
      
      it("missing chat id") {
        let message = CHMessage(
          chatId: "+!@#!@",
          message: self.testMessage,
          type: .Default)
        waitUntil (timeout: 10) { done in
          _ = message.send().subscribe(onNext: { (msg) in
            expect(msg).to(beNil())
          }, onError: { (error) in
            expect(error).notTo(beNil())
            done()
          })
        }
      }
      
      it("normal image") {
        let tempImage = CHAssets.getImage(named: "audio")
        let tempData = UIImagePNGRepresentation(tempImage!)
        let file = CHFile(data: tempData!, category: "image")
        
        var message = CHMessage(chatId: self.userChatId,
                              message: self.testMessage,
                              type: .Default)
        message.file = file
        
        waitUntil (timeout: 30) { done in
          _ = message.send().subscribe(onNext: { (msg) in
            expect(msg).notTo(beNil())
            done()
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        }
      }
 
      it("normal file") {
        guard let path = Bundle(for: ChannelIO.self).path(forResource: "countryInfo", ofType: "json") else {
          print("error to read file")
          expect(false).to(beTrue())
          return
        }
        do {
          let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
          var file = CHFile(data: data, category:"json")
          file.name = "test_json.json"
          
          var message = CHMessage(chatId: self.userChatId,
                                message: self.testMessage,
                                type: .Default)
          message.file = file
          
          waitUntil (timeout: 30) { done in
            _ = message.send().subscribe(onNext: { (msg) in
              expect(msg).notTo(beNil())
              done()
            }, onError: { (error) in
              expect(error).to(beNil())
              
            })
          }
          
        } catch let error {
          expect(error).to(beNil())
        }
      }

    }
    
    describe("eqaulity") {
      it("normal") {
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default)

        let messagetwo = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default)
        
        expect(message == messagetwo).to(beFalse())
      }
      
      it("same id") {
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          id: "123")
        
        let messagetwo = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          id: "123")
        
        expect(message == messagetwo).to(beTrue())
      }
      
      it("different type") {
        let message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          id: "123")
        
        let messagetwo = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .WelcomeMessage,
          id: "123")
        
        expect(message == messagetwo).to(beFalse())
      }
      
      it("different progress") {
        var message = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          id: "123")
        message.progress = 0.5
        var messagetwo = CHMessage(
          chatId: self.userChatId,
          message: self.testMessage,
          type: .Default,
          id: "123")
        messagetwo.progress = 0.1
        expect(message == messagetwo).to(beFalse())
      }
    }
  }
  
}
