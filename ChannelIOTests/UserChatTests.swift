//
//  UserChatTests.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
import ObjectMapper
import RxSwift

@testable import ChannelIO

class UserChatTests: QuickSpec {
  var loadedChat: CHUserChat?
  let manager: CHManager = CHManager(
    id: "22136",
    name: "manager_name",
    avatarUrl: "url",
    username: "user_name"
  )
  var createdUserChats: [CHUserChat?] = []
  var data: Data?
  var json: JSON?
  
  let disposeBag = DisposeBag()
  
  override func spec() {
    beforeSuite {
      guard
        let url = Bundle(for: ChannelIO.self).url(forResource: "userChats", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let json = try? JSON(data: data) else {
        return
      }
      self.data = data
      self.json = json
      
      let settings = ChannelPluginSettings(pluginKey: "06ccfc12-a9fd-4c68-b364-5d19f81a60dd")
      waitUntil(timeout: 10) { done in
        ChannelIO.boot(with: settings) { (completion, user) in
          done()
        }
      }
      mainStore.dispatch(UpdateManager(payload: self.manager))
    }

    afterSuite {
      for chat in self.createdUserChats {
        guard let chat = chat else { continue }
        chat.remove().subscribe(onNext: { (result) in
          expect(result).to(beNil())
        }, onError: { (error) in
          expect(error).to(beNil())
        }).disposed(by: self.disposeBag)
      }
      ChannelIO.shutdown()
    }
    
    beforeEach {
      let chats = Mapper<CHUserChat>().mapArray(JSONObject: self.json?["userChats"].object)
      self.loadedChat = chats?.first
    }
    
    describe("Creation") {
      context("userChat created by default constructor") {
        it("should contain defualt value") {
          let userChat = CHUserChat()
          expect(userChat.id).to(equal(""))
          expect(userChat.personType).to(equal(""))
          expect(userChat.channelId).to(equal(""))
          expect(userChat.state).to(equal(.ready))
          expect(userChat.review).to(equal(""))
          expect(userChat.createdAt).to(beNil())
          expect(userChat.openedAt).to(beNil())
          expect(userChat.updatedAt).to(beNil())
          expect(userChat.followedAt).to(beNil())
          expect(userChat.resolvedAt).to(beNil())
          expect(userChat.closedAt).to(beNil())
          expect(userChat.assigneeId).to(beNil())
          expect(userChat.assigneeType).to(beNil())
          expect(userChat.appMessageId).to(beNil())
          expect(userChat.resolutionTime).to(equal(0))
        }
      }
      
      context("userChat created by mock file") {
        it("should contain proper values") {
          guard let userChat = self.loadedChat else {
            fatalError()
          }
          
          expect(userChat.id).to(equal("4677418"))
          expect(userChat.personType).to(equal("User"))
          expect(userChat.personId).to(equal("33"))
          expect(userChat.channelId).to(equal("7"))
          expect(userChat.review).to(equal("test"))
          expect(userChat.assigneeId).to(equal("22136"))
          expect(userChat.assigneeType).to(equal("Manager"))
          expect(userChat.appMessageId).to(equal("5d9844a49c60575c"))
          expect(userChat.resolutionTime).to(equal(87102))
          expect(userChat.state).to(equal(.closed))
        }
      }
    }
    
    describe("Variable") {
      describe("assignee") {
        context("assigneeType or assigneeId is invalid") {
          it("should return nil") {
            self.loadedChat?.assigneeId = "100"
            self.loadedChat?.assigneeType = "Manager"
            expect(self.loadedChat?.assignee).to(beNil())
          }
        }
        
        context("assigneeType or assigneeId is valid") {
          it("should return proper assignee") {
            self.loadedChat?.assigneeId = self.manager.id
            self.loadedChat?.assigneeType = "Manager"
            if let assignee = self.loadedChat?.assignee as? CHManager {
              expect(assignee).to(equal(self.manager))
            } else {
              fatalError()
            }
          }
        }
      }
      
      describe("name") {
        context("assignee and channel name not exist") {
          it("should return unknown") {
            self.loadedChat?.assigneeId = ""
            self.loadedChat?.assigneeType = "Manager"
            expect(self.loadedChat?.name).to(equal("Unknown"))
          }
        }
        
        context("assignee not exist and channel name exist") {
          it("should return channel name") {
            self.loadedChat?.assigneeId = ""
            self.loadedChat?.assigneeType = "Manager"
            self.loadedChat?.channel = CHChannel(id: "7", name: "channel_name")
            expect(self.loadedChat?.name).to(equal("channel_name"))
          }
        }
        
        context("assignee exist") {
          it("name should return assignee name") {
            self.loadedChat?.assigneeId = self.manager.id
            self.loadedChat?.assigneeType = "Manager"
            expect(self.loadedChat?.name).to(equal("manager_name"))
          }
        }
      }
      
      describe("readableUpdatedAt") {
        context("createdAt of lastMessage not exist") {
          it("should return empty string") {
            self.loadedChat?.lastMessage = nil
            expect(self.loadedChat?.readableUpdatedAt).to(equal(""))
          }
        }
        
        context("createdAt of lastMessage exist") {
          it("should return createdAt timpstamp"){
            self.loadedChat?.lastMessage = CHMessage(createdAt: Date(timeIntervalSince1970: 10000000))
            expect(self.loadedChat?.readableUpdatedAt).to(equal("1970/4/27"))
          }
        }
      }
      
      describe("isLocal") {
        context("id has local by prefix") {
          it("should return true") {
            self.loadedChat?.id = "local1234"
            expect(self.loadedChat?.isLocal).to(beTrue())
          }
        }
        
        context("id doesnt have local by prefix") {
          it("should return false") {
            expect(self.loadedChat?.isLocal).to(beFalse())
          }
        }
      }
      
      describe("fromNudge") {
        context("id has nudgeChat by prefix") {
          it("should return true") {
            self.loadedChat?.id = "local_nudgeChat1234"
            expect(self.loadedChat?.fromNudge).to(beTrue())
          }
        }
        
        context("id doesnt have nudgeChat by prefix") {
          it("should return false") {
            expect(self.loadedChat?.fromNudge).to(beFalse())
          }
        }
      }
      
      describe("nudgeId") {
        context("id has nudgeChat by prefix") {
          it("should return proper id") {
            self.loadedChat?.id = "local_nudgeChat1234"
            expect(self.loadedChat?.nudgeId).to(equal("1234"))
          }
        }
        
        context("id doesnt have nudgeChat by prefix") {
          it("should return original id") {
            self.loadedChat?.id = "1234"
            expect(self.loadedChat?.nudgeId).to(equal("1234"))
          }
        }
      }
      
      describe("isActive") {
        context("state is ready or supporting or unassigned or assigned or holding") {
          it("should return true") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isActive).to(beTrue())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isActive).to(beTrue())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isActive).to(beTrue())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isActive).to(beTrue())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isActive).to(beTrue())
          }
        }
        
        context("state is closed or solved or removed") {
          it("should return false") {
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isActive).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isActive).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isActive).to(beFalse())
          }
        }
      }
      
      describe("isClosed") {
        context("state is closed") {
          it("should return true") {
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isClosed).to(beTrue())
          }
        }
        
        context("state is not closed") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isClosed).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isClosed).to(beFalse())
          }
        }
      }
      
      describe("isRemoved") {
        context("state is removed") {
          it("should return true") {
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isRemoved).to(beTrue())
          }
        }
        
        context("state is not removed") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isRemoved).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isRemoved).to(beFalse())
          }
        }
      }
      
      describe("isSolved") {
        context("state is solved") {
          it("should return true") {
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isSolved).to(beTrue())
          }
        }
        
        context("state is not sloved") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isSolved).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isSolved).to(beFalse())
          }
        }
      }
      
      describe("isCompleted") {
        context("state is closed or solved or removed") {
          it("should return true") {
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isCompleted).to(beTrue())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isCompleted).to(beTrue())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isCompleted).to(beTrue())
          }
        }
        
        context("state is ready or supporting or unassigned or assigned or holding") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isCompleted).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isCompleted).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isCompleted).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isCompleted).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isCompleted).to(beFalse())
          }
        }
      }
      
      describe("isReadyOrOpen") {
        context("state is ready or open") {
          it("should return true") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isReadyOrOpen).to(beTrue())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isReadyOrOpen).to(beTrue())
          }
        }
        
        context("state is not ready and not open") {
          it("should return false") {
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isReadyOrOpen).to(beFalse())
          }
        }
      }
      
      describe("isUnassigned") {
        context("state is unassigned") {
          it("should return true") {
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isUnassigned).to(beTrue())
          }
        }
        
        context("state is not unassigned") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isUnassigned).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isUnassigned).to(beFalse())
          }
        }
      }
      
      describe("isReady") {
        context("state is ready") {
          it("should return true") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isReady).to(beTrue())
          }
        }
        
        context("state is not ready") {
          it("should return false") {
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isReady).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isReady).to(beFalse())
          }
        }
      }
      
      describe("isEngaged") {
        context("state is sloved or closed or assigned") {
          it("should return true") {
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isEngaged).to(beTrue())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isEngaged).to(beTrue())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isEngaged).to(beTrue())
          }
        }
        
        context("state is ready or supporting or unassigned or hoding or removed") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isEngaged).to(beFalse())
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isEngaged).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isEngaged).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isEngaged).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isEngaged).to(beFalse())
          }
        }
      }
      
      describe("isSupporting") {
        context("state is supporting") {
          it("should return true") {
            self.loadedChat?.state = .supporting
            expect(self.loadedChat?.isSupporting).to(beTrue())
          }
        }
        
        context("state is not supporting") {
          it("should return false") {
            self.loadedChat?.state = .ready
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .unassigned
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .assigned
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .holding
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .solved
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .removed
            expect(self.loadedChat?.isSupporting).to(beFalse())
            self.loadedChat?.state = .closed
            expect(self.loadedChat?.isSupporting).to(beFalse())
          }
        }
      }
    }
    
    describe("Function") {
      describe("remove") {
        context("remove userChat from plugin") {
          it("should pass with nil") {
            waitUntil(timeout: 10) { done in
              CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
                self.createdUserChats.append(result.userChat)
                if let chat = result.userChat {
                  chat.remove().subscribe(onNext: { (result) in
                    expect(result).to(beNil())
                    done()
                  }, onError: { (error) in
                    expect(error).to(beNil())
                    done()
                  }).disposed(by: self.disposeBag)
                } else {
                  fatalError()
                }
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("close") {
        context("close userChat from plugin") {
          it("should pass with nil") {
//            waitUntil(timeout: 10) { done in
//              CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
//                self.createdUserChats.append(result.userChat)
//                if let chat = result.userChat {
//                  let message = CHMessage.createLocal(chatId: chat.id, text: "test")
//                  message.send().subscribe(onNext: { (msg) in
//                    chat.close(mid: msg.id).subscribe(onNext: { (result) in
//                      expect(result).to(beNil())
//                      done()
//                    }, onError: { (error) in
//                      expect(error).to(beNil())
//                      done()
//                    }).disposed(by: self.disposeBag)
//                  }, onError: { (error) in
//                    done()
//                  }).disposed(by: self.disposeBag)
//              } else {
//                  fatalError()
//                }
//              }, onError: { (error) in
//                expect(error).to(beNil())
//                done()
//              }).disposed(by: self.disposeBag)
//            }
          }
        }
      }
      
      describe("review") {
        context("review userChat from plugin") {
          it("") {
//            waitUntil(timeout: 10) { done in
//              CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
//                self.createdUserChats.append(result.userChat)
//                if let chat = result.userChat {
//                  let message = CHMessage.createLocal(chatId: chat.id, text: "test", originId: "1234", mutable: true)
//                  chat.review(mid: message.id, rating: .like, requestId: "").subscribe(onNext: { (result) in
//                    expect(result).to(beNil())
//                    done()
//                  }, onError: { (error) in
//                    expect(error).to(beNil())
//                    done()
//                  }).disposed(by: self.disposeBag)
//                } else {
//                  fatalError()
//                }
//              }, onError: { (error) in
//                expect(error).to(beNil())
//                done()
//              }).disposed(by: self.disposeBag)
//            }
          }
        }
      }
      
      describe("shouldRequestRead") {
        context("chat has diffrent update miliseconds or session alert") {
          it("should return true") {
            var firstChat = self.loadedChat
            firstChat?.updatedAt = Date(timeIntervalSinceReferenceDate: 1)
            firstChat?.session = CHSession()
            firstChat?.session?.alert = 1
            
            var secondChat = self.loadedChat
            secondChat?.updatedAt = Date(timeIntervalSinceReferenceDate: 2)
            secondChat?.session = CHSession()
            secondChat?.session?.alert = 1
            expect(firstChat?.shouldRequestRead(otherChat: secondChat)).to(beTrue())
            
            secondChat?.updatedAt = Date(timeIntervalSinceReferenceDate: 1)
            secondChat?.session = CHSession()
            secondChat?.session?.alert = 2
            expect(firstChat?.shouldRequestRead(otherChat: secondChat)).to(beTrue())
          }
        }
        
        context("chat has same update miliseconds and session alert") {
          it("should return false") {
            var firstChat = self.loadedChat
            firstChat?.updatedAt = Date(timeIntervalSinceReferenceDate: 1)
            firstChat?.session = CHSession()
            firstChat?.session?.alert = 1
            
            var secondChat = self.loadedChat
            secondChat?.updatedAt = Date(timeIntervalSinceReferenceDate: 1)
            secondChat?.session = CHSession()
            secondChat?.session?.alert = 1
            expect(firstChat?.shouldRequestRead(otherChat: secondChat)).to(beFalse())
          }
        }
      }
      
      describe("read") {
        context("read userChat from plugin") {
          it("should pass and update session") {
            
          }
        }
      }
      
      describe("get") {
        context("get userchat with chat id") {
          it("should return proper userChat") {
            waitUntil(timeout: 10) { done in
              CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
                self.createdUserChats.append(result.userChat)
                if let id = result.userChat?.id {
                  CHUserChat.get(userChatId: id).subscribe(onNext: { (result) in
                    expect(result).to(beAnInstanceOf(ChatResponse.self))
                    done()
                  }, onError: { (error) in
                    expect(error).to(beNil())
                    done()
                  }).disposed(by: self.disposeBag)
                } else {
                  fatalError()
                }
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("getChats") {
        context("get userChats from proper plugin") {
          it("should return userchats") {
            waitUntil(timeout: 10) { done in
              CHUserChat.getChats().subscribe(onNext: { (result) in
                expect(result).to(beAnInstanceOf([String: Any?].self))
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("create") {
        context("userChat create at proper plugin") {
          it("should return ChatResponse") {
            waitUntil(timeout: 10) { done in
              CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
                self.createdUserChats.append(result.userChat)
                expect(result).to(beAnInstanceOf(ChatResponse.self))
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("becomeActive") {
        context("currentChat isReadyOrOpen is true and nextChat isReadyOrOpen is false") {
          it("should return true") {
            var currentChat = CHUserChat()
            currentChat.state = .ready
            var nextChat = CHUserChat()
            nextChat.state = .closed
            expect(CHUserChat.becomeActive(current: currentChat, next: nextChat)).to(beTrue())
          }
        }
        context("currentChat isReadyOrOpen is false or nextChat isReadyOrOpen is true") {
          it("should return false") {
            var currentChat = CHUserChat()
            currentChat.state = .ready
            var nextChat = CHUserChat()
            nextChat.state = .ready
            expect(CHUserChat.becomeActive(current: currentChat, next: nextChat)).to(beFalse())
          }
        }
      }
      
      describe("becomeOpen") {
        context("currentChat isSolved is false or nextChat isReadyOrOpen is false") {
          it("should return false") {
            var currentChat = CHUserChat()
            currentChat.state = .ready
            var nextChat = CHUserChat()
            nextChat.state = .closed
            expect(CHUserChat.becomeOpen(current: currentChat, next: nextChat)).to(beFalse())
          }
        }
        
        context("currentChat isSolved is true and nextChat isReadyOrOpen is true") {
          it("should return true") {
            var currentChat = CHUserChat()
            currentChat.state = .solved
            var nextChat = CHUserChat()
            nextChat.state = .ready
            expect(CHUserChat.becomeOpen(current: currentChat, next: nextChat)).to(beTrue())
          }
        }
      }
      
      describe("createLocal") {
        context("it has valid writer and variant") {
          it("should return proper tuple value") {
            let writer = CHManager()
            let variant = CHNudgeVariant(id: "1234", nudgeId: "1234", name: "nudge_name", title: "title_name")
            let (chat, message, session) = CHUserChat.createLocal(writer: writer, variant: variant)
            expect(chat).to(beAnInstanceOf(CHUserChat.self))
            expect(message).to(beAnInstanceOf(CHMessage.self))
            expect(session).to(beAnInstanceOf(CHSession.self))
          }
        }
      }
    }
  }
}
