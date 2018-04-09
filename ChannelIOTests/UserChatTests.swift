//
//  UserChatTests.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Quick
import Nimble
import SwiftDate

@testable import CHPlugin

class UserChatTests: QuickSpec {

  override func spec() {
    
    it("create") {
      let date = Date()
      let userChat = CHUserChat(
        id: "7", personType: "", personId: "",
        channelId: "", bindFromId: "", state: "",
        review: "", createdAt: nil, openedAt: nil,
        updatedAt: nil, followedAt: nil, resolvedAt: nil,
        followedBy: "", lastMessageId: "123", talkedManagerIds: [],
        resolutionTime: 0, lastMessage: nil, session: nil,
        managers: [], channel: nil)
      
      expect(userChat).toNot(beNil())
      expect(userChat.updatedAt).to(equal(date))
      expect(userChat.id).to(equal("7"))
      expect(userChat.lastMessageId).to(equal("123"))
    }
    
    describe("name") {
      var userChat = CHUserChat()
      
      it("should return unknown") {
        expect(userChat.name).to(equal("Unknown"))
      }
      
      it("should return manager name") {
        userChat.managers = [CHManager(id:"12",
                                   name:"manager",
                                   avatarUrl:nil,
                                   initial:"m",
                                   color:"#123141",
                                   username:"manager name")]
        expect(userChat.name).to(equal("manager"))
      }
      
      it("should return multiple") {
        let manager = CHManager(id:"12",
                              name:"manager",
                              avatarUrl:nil,
                              initial:"m",
                              color:"#123141",
                              username:"manager name")
        
        userChat.managers = [manager, manager]
        expect(userChat.name).to(equal("\(manager.name) and 1 others"))
      }
    }
    
    describe("updatedAt") {
      var userChat = CHUserChat()
      userChat.updatedAt = Date()
      let now = DateInRegion()
      
      it("should return today") {
        expect(userChat.readableUpdatedAt).to(equal("\(now.hour):\(now.minute)"))
      }
      
      it("should return empty string") {
        userChat.updatedAt = nil
        expect(userChat.readableUpdatedAt).to(equal(""))
      }
    }
  }

}
