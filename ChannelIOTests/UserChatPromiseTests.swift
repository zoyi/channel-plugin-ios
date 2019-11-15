//
//  UserChatPromiseTests.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//


import Quick
import Nimble
//import RxSwift

@testable import ChannelIO

class UserChatPromiseTests: QuickSpec {
  
  override func spec() {
    var userChatId = ""

    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "7")
      PrefStore.setCurrentUserId(userId: "58a154dec843f78f")
    }
    
    it("create user chat") {
//      waitUntil(timeout:10) { done in
//        _ = UserChatPromise.createChat(pluginId: "7")
//          .subscribe(onNext: { (data) in
//            userChatId = data.userChat?.id ?? ""
//            print("new chat id : \(userChatId)")
//          }, onError: { (error) in
//            expect(error).to(beNil())
//            done()
//          }, onCompleted: {
//            done()
//          })
//      }
    }

    describe("get user chats") {
      it("normal") {
//        waitUntil(timeout:5) { done in
//          _ = UserChatPromise.getChats(limit: 20)
//            .subscribe(onNext: { (data) in
//
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          }, onCompleted: {
//            done()
//          })
//        }
      }
    }
    
    describe("get user chat") {
      it("normal") {
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.getChat(userChatId: userChatId)
//            .subscribe(onNext: { (data) in
//
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          }, onCompleted: {
//            done()
//          })
//        }
      }
      
      it("invalid chat id") {
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.getChat(userChatId: "-1")
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).notTo(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
    }
    
    describe("get message") {
      it("normal"){
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.getMessages(userChatId: userChatId,
//                                          since: "",
//                                          limit: 30,
//                                          sortOrder: "DESC")
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).to(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
      
      it("invalid sortOrder"){
        waitUntil(timeout:10) { done in
          _ = UserChatPromise.getMessages(userChatId: userChatId,
                                          since: "",
                                          limit: 30,
                                          sortOrder: "DDDD")
            .subscribe(onNext: { (data) in
              
            }, onError: { (error) in
              expect(error).notTo(beNil())
              done()
            }, onCompleted: {
              done()
            })
        }
      }
      
      it("invalid since"){
        waitUntil(timeout:10) { done in
          _ = UserChatPromise.getMessages(userChatId: userChatId,
                                          since: "-1111111",
                                          limit: 30,
                                          sortOrder: "DDDD")
            .subscribe(onNext: { (data) in
              
            }, onError: { (error) in
              expect(error).notTo(beNil())
              done()
            }, onCompleted: {
              done()
            })
        }
      }
      
      it("invalid chat id"){
        waitUntil(timeout:10) { done in
          _ = UserChatPromise.getMessages(userChatId: "",
                                          since: "",
                                          limit: 30,
                                          sortOrder: "DDDD")
            .subscribe(onNext: { (data) in
              
            }, onError: { (error) in
              expect(error).notTo(beNil())
              done()
            }, onCompleted: {
              done()
            })
        }
      }
    }
    
    describe("create message") {
      it("normal") {
//        let requestId = "\(Date().timeIntervalSince1970 * 1000)"
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.createMessage(
//              userChatId: userChatId,
//              message: "unit test message",
//              requestId: requestId)
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).to(beNil())
//            }, onCompleted: {
//              done()
//            })
//        }
      }
      
      it("invalid chat id") {
        let requestId = "\(Date().timeIntervalSince1970 * 1000)"
        waitUntil(timeout:10) { done in
          _ = UserChatPromise.createMessage(
            userChatId: "=11",
            message: "unit test message",
            requestId: requestId)
            .subscribe(onNext: { (data) in
              
            }, onError: { (error) in
              expect(error).notTo(beNil())
              done()
            }, onCompleted: {
              done()
            })
        }
      }
      
      it("empty string") {
        let requestId = "\(Date().timeIntervalSince1970 * 1000)"
        waitUntil(timeout:10) { done in
          _ = UserChatPromise.createMessage(
            userChatId: userChatId,
            message: "",
            requestId: requestId)
            .subscribe(onNext: { (data) in
              
            }, onError: { (error) in
              expect(error).notTo(beNil())
              done()
            }, onCompleted: {
              done()
            })
        }
      }
    }
    
    describe("upload file") {
      it("normal") {
//        let requestId = "\(Date().timeIntervalSince1970 * 1000)"
//        waitUntil(timeout:30) { done in
//          let tempImage = CHAssets.getImage(named: "audio")
//          let tempData = UIImagePNGRepresentation(tempImage!)
//          _ = UserChatPromise.uploadFile(name: "unit test file",
//                                         file: tempData!,
//                                         requestId: requestId,
//                                         userChatId: userChatId,
//                                         category: "image")
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).to(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
      
      it("invalid chat id") {
//        let requestId = "\(Date().timeIntervalSince1970 * 1000)"
//        waitUntil(timeout:30) { done in
//          let tempImage = CHAssets.getImage(named: "audio")
//          let tempData = UIImagePNGRepresentation(tempImage!)
//          _ = UserChatPromise.uploadFile(name: "unit test file",
//                                         file: tempData!,
//                                         requestId: requestId,
//                                         userChatId: userChatId,
//                                         category:"image")
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).notTo(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
    }
  
    describe("read all") {
//      it("normal"){
//        waitUntil(timeout:30) { done in
//          _ = UserChatPromise.setMessageRead(userChatId: userChatId)
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).to(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
//      }
//
//      it("invalid chat id") {
//        waitUntil(timeout:30) { done in
//          _ = UserChatPromise.setMessageRead(userChatId: "+123.x")
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).notTo(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
//      }
    }
    
    describe("close user chat") {
      it("normal"){
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.close(userChatId: userChatId)
//            .subscribe(onNext: { (data) in
//
//            }, onError: { (error) in
//              expect(error).to(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
      
      it("invalid chat id") {
//        waitUntil(timeout:10) { done in
//          _ = UserChatPromise.close(userChatId: "ababab")
//            .subscribe(onNext: { (data) in
//              
//            }, onError: { (error) in
//              expect(error).notTo(beNil())
//              done()
//            }, onCompleted: {
//              done()
//            })
//        }
      }
    }
  }
}
