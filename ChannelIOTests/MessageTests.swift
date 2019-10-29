//
//  MessageTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
import ObjectMapper
import RxSwift
@testable import ChannelIO

class MessageTests: QuickSpec {
  
  var loadedMessage: CHMessage?
  var loadedUerChat: CHUserChat?
  var data: Data?
  var json: JSON?
  let userChatId = "1234"
  
  let disposeBag = DisposeBag()
  
  override func spec() {
    beforeSuite {
      guard
        let url = Bundle(for: ChannelIO.self).url(forResource: "messages", withExtension: "json"),
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
      
      waitUntil(timeout: 10) { done in
        CHUserChat.create(pluginId: mainStore.state.plugin.id).subscribe(onNext: { (result) in
          if let chat = result.userChat {
            self.loadedUerChat = chat
            done()
          } else {
            fatalError()
          }
        }, onError: { (error) in
          fatalError()
        }).disposed(by: self.disposeBag)
      }
    }
    
    afterSuite {
      waitUntil(timeout: 10) { done in
        self.loadedUerChat?.remove().subscribe(onNext: { (result) in
          done()
        }, onError: { (error) in
          done()
        }).disposed(by: self.disposeBag)
      }
      ChannelIO.shutdown()
    }
    
    beforeEach {
      let messages = Mapper<CHMessage>().mapArray(JSONObject: self.json?["messages"].object)
      self.loadedMessage = messages?.first
    }
    
    describe("Creation") {
      context("userChat created by default constructor") {
        it("should contain defualt value") {
          let message = CHMessage(chatId: self.userChatId, message: "test", type: .Default)
          expect(message.requestId).notTo(equal(""))
          expect(message.id).to(equal(message.requestId))
          expect(message.chatId).to(equal(self.userChatId))
          expect(message.messageType).to(equal(.Default))
          expect(message.entity).to(beNil())
          expect(message.action).to(beNil())
          expect(message.file).to(beNil())
          expect(message.webPage).to(beNil())
          expect(message.log).to(beNil())
          expect(message.progress).to(equal(1))
        }
      }
      
      context("userChat created by mock file") {
        it("should contain proper values") {
          guard let message = self.loadedMessage else {
            fatalError()
          }
          expect(message.channelId).to(equal("7"))
          expect(message.requestId).to(equal("a997c216-d054-426b-9efe-9ca4f7c98b80"))
          expect(message.id).to(equal("5da5990e71ed9f2e"))
          expect(message.chatId).to(equal(self.userChatId))
          expect(message.message).to(equal("test"))
          expect(message.messageType).to(equal(.Default))
          expect(message.entity).to(beNil())
          expect(message.action).to(beNil())
          expect(message.file).to(beNil())
          expect(message.webPage).to(beNil())
          expect(message.log).to(beNil())
          expect(message.progress).to(equal(1))
          expect(message.language).to(equal("ko"))
        }
      }
    }
        
    describe("Variable") {
      describe("readableDate") {
        context("message has valid createdAt") {
          it("should return proper string") {
            expect(self.loadedMessage?.readableDate).to(equal("2019-10-15"))
          }
        }
      }
      
      describe("readableCreatedAt") {
        context("message has valid createdAt") {
          it("should return proper string") {
            expect(self.loadedMessage?.readableCreatedAt).to(equal("7:01 PM"))
            self.loadedMessage?.createdAt = Date(timeIntervalSinceReferenceDate: 1)
            expect(self.loadedMessage?.readableCreatedAt).to(equal("9:00 AM"))
          }
        }
      }
      
      describe("logMessage") {
        context("message has image") {
          it("should return proper text") {
            var file = CHFile()
            file.previewThumb = CHImageMeta()
            file.image = true
            self.loadedMessage?.file = file
            expect(self.loadedMessage?.logMessage)
              .to(equal(CHAssets.localized("ch.notification.upload_image.description")))
          }
        }
        
        context("message has jus file") {
          it("should return proper text") {
            let file = CHFile()
            self.loadedMessage?.file = file
            expect(self.loadedMessage?.logMessage)
              .to(equal(CHAssets.localized("ch.notification.upload_file.description")))
          }
        }
        
        context("message has log and log is closed") {
          it("should return proper text") {
            var log = CHLog()
            log.action = "closed"
            self.loadedMessage?.log = log
            expect(self.loadedMessage?.logMessage)
              .to(equal(CHAssets.localized("ch.review.require.preview")))
          }
        }
        
        context("message doesnt have file and log") {
          it("should return nil") {
            expect(self.loadedMessage?.logMessage).to(beNil())
          }
        }
      }
      
      describe("isWelcome") {
        context("message has welcome option") {
          it("should return true") {
            self.loadedMessage?.botOption = ["welcome": true]
            expect(self.loadedMessage?.isWelcome).to(beTrue())
          }
        }
        
        context("message doesnt have welcome option") {
          it("should return false") {
            expect(self.loadedMessage?.isWelcome).to(beFalse())
          }
        }
      }
      
      describe("isDeleted") {
        context("message has log and log action is deleted") {
          it("should return true") {
            var log = CHLog()
            log.action = "delete_message"
            self.loadedMessage?.log = log
            expect(self.loadedMessage?.isDeleted).to(beTrue())
          }
        }
        
        context("message doesnt have log or log action is not deleted") {
          it("should return false") {
            var log = CHLog()
            log.action = "closed"
            self.loadedMessage?.log = log
            expect(self.loadedMessage?.isDeleted).to(beFalse())
          }
        }
      }
    }
    
    describe("Function") {
      describe("isEmpty") {
        context("if messageV2 or message is not empty") {
          it("should return false") {
            expect(self.loadedMessage?.isEmpty()).to(beFalse())
            self.loadedMessage?.messageV2 = NSAttributedString(string: "test")
            self.loadedMessage?.message = ""
            expect(self.loadedMessage?.isEmpty()).to(beFalse())
            self.loadedMessage?.messageV2 = NSAttributedString(string: "")
            self.loadedMessage?.message = "test"
            expect(self.loadedMessage?.isEmpty()).to(beFalse())
          }
        }
        
        context("if message and messageV2 is empty") {
          it("should return true") {
            self.loadedMessage?.message = ""
            self.loadedMessage?.messageV2 = NSAttributedString(string: "")
            expect(self.loadedMessage?.isEmpty()).to(beTrue())
          }
        }
      }
      
      describe("isSameWriter") {
        context("messages have same personId and personType") {
          it("should return true") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.personId = "123"
            firstMessage?.personType = "Manager"
            secondMessage?.personId = "123"
            secondMessage?.personType = "Manager"
            expect(firstMessage?.isSameWriter(other: secondMessage)).to(beTrue())
          }
        }
        
        context("messages have diffrent personId and personType") {
          it("should return false") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.personId = "123"
            firstMessage?.personType = "Manager"
            secondMessage?.personId = "124"
            secondMessage?.personType = "Manager"
            expect(firstMessage?.isSameWriter(other: secondMessage)).to(beFalse())
          }
        }
      }
      
      describe("isSameDate") {
        context("messages have same created date") {
          it("should return true") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            expect(firstMessage?.isSameDate(other: secondMessage)).to(beTrue())
          }
        }
        
        context("messages have diffrent created date") {
          it("should return false") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 100000)
            expect(firstMessage?.isSameDate(other: secondMessage)).to(beFalse())
          }
        }
      }
      
      describe("isContinue") {
        context("messages have same minute and hour and writer") {
          it("should return true") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.personId = "123"
            firstMessage?.personType = "Manager"
            firstMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            secondMessage?.personId = "123"
            secondMessage?.personType = "Manager"
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            expect(firstMessage?.isContinue(other: secondMessage)).to(beTrue())
          }
        }
        
        context("messages have diffrent minute or hour or writer") {
          it("should return false") {
            var firstMessage = self.loadedMessage
            var secondMessage = self.loadedMessage
            firstMessage?.personId = "123"
            firstMessage?.personType = "Manager"
            firstMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            
            secondMessage?.personId = "123"
            secondMessage?.personType = "Manager"
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 10000)
            expect(firstMessage?.isContinue(other: secondMessage)).to(beFalse())
            
            secondMessage?.personId = "124"
            secondMessage?.personType = "Manager"
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 1)
            expect(firstMessage?.isContinue(other: secondMessage)).to(beFalse())
            
            secondMessage?.personId = "124"
            secondMessage?.personType = "Manager"
            secondMessage?.createdAt = Date(timeIntervalSinceNow: 1000)
            expect(firstMessage?.isContinue(other: secondMessage)).to(beFalse())
          }
        }
      }
      
      describe("createLocal") {
        context("it create local message") {
          it("should return proper message") {
            let message = CHMessage.createLocal(
              chatId: self.loadedUerChat?.id ?? "",
              text: "test",
              originId: "1234",
              key: "test_key"
            )
            expect(message.chatId).to(equal(self.loadedUerChat?.id))
            expect(message.message).to(equal("test"))
            expect(message.submit).notTo(beNil())
            expect(message.mutable).to(beTrue())
          }
        }
      }
      
      describe("getMessages") {
        context("get messages from userChat") {
          it("should return proper userChat messages") {
            waitUntil(timeout: 10) { done in
              CHMessage.getMessages(
                userChatId: self.loadedUerChat?.id ?? "",
                since: "",
                limit: 30,
                sortOrder: "DESC"
              ).subscribe(onNext: { (result) in
                expect(result).to(beAnInstanceOf([String: Any].self))
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("isMine") {
        context("message has same user id") {
          it("should return true") {
            self.loadedMessage?.entity = mainStore.state.user
            expect(self.loadedMessage?.isMine()).to(beTrue())
          }
        }
      }
      
      describe("updateProfile") {
        context("update message profile with key and value") {
          it("") {
//            waitUntil(timeout: 10) { done in
//              let localMessage = CHMessage.createLocal(
//                chatId: self.loadedUerChat?.id ?? "",
//                text: "test"
//              )
//              localMessage.send().subscribe(onNext: { (message) in
//                message.updateProfile(with: "name", value: "TESTER")
//                  .subscribe(onNext: { (result) in
//                    expect(result).to(beAnInstanceOf(CHMessage.self))
//                    done()
//                  }, onError: { (error) in
//                    expect(error).to(beNil())
//                    done()
//                }).disposed(by: self.disposeBag)
//              }, onError: { (error) in
//                expect(error).to(beNil())
//                done()
//              }).disposed(by: self.disposeBag)
//            }
          }
        }
      }
      
      describe("send") {
        context("send image") {
          it("should pass with nil") {
            let tempImage = CHAssets.getImage(named: "audio")
            let tempData = tempImage!.pngData()
            let file = CHFile(data: tempData!, category: "image")
            
            var localMessage = CHMessage(
              chatId: self.loadedUerChat?.id ?? "",
              message: "test",
              type: .Default
            )
            localMessage.file = file
            waitUntil (timeout: 10) { done in
              localMessage.send().subscribe(onNext: { (msg) in
                expect(msg).notTo(beNil())
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
        
        context("normal file") {
          it("should pass with nil") {
            let file = CHFile(data: self.data ?? Data(), category: "json")
            var localMessage = CHMessage(
              chatId: self.loadedUerChat?.id ?? "",
              message: "test",
              type: .Default
            )
            localMessage.file = file
            waitUntil (timeout: 10) { done in
              localMessage.send().subscribe(onNext: { (msg) in
                expect(msg).notTo(beNil())
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
        
        context("send video") {
          it("should pass with nil") {
//            let file = CHFile(data: video, category: "video")
//
//            var localMessage = CHMessage(
//              chatId: self.loadedUerChat?.id ?? "",
//              message: "test",
//              type: .Default
//            )
//            localMessage.file = file
//            waitUntil (timeout: 10) { done in
//              localMessage.send().subscribe(onNext: { (msg) in
//                expect(msg).notTo(beNil())
//                done()
//              }, onError: { (error) in
//                expect(error).to(beNil())
//                done()
//              }).disposed(by: self.disposeBag)
//            }
          }
        }
        
        context("send text") {
          it("should pass with nil") {
            let localMessage = CHMessage(
              chatId: self.loadedUerChat?.id ?? "",
              message: "test",
              type: .Default
            )
            waitUntil(timeout: 10) { done in
              localMessage.send().subscribe(onNext: { (message) in
                expect(message).to(beAnInstanceOf(CHMessage.self))
                done()
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
      
      describe("translate") {
        context("translate message with language") {
          it("should return translated language") {
            waitUntil(timeout: 10) { done in
              let localMessage = CHMessage(
                chatId: self.loadedUerChat?.id ?? "",
                message: "welcome",
                type: .Default
              )
              localMessage.send().subscribe(onNext: { (message) in
                message.translate(to: "ko")
                  .subscribe(onNext: { (result) in
                    expect(result).to(beAnInstanceOf(String.self))
                    expect(result).to(equal("환영해"))
                    done()
                  }, onError: { (error) in
                    expect(error).to(beNil())
                    done()
                }).disposed(by: self.disposeBag)
              }, onError: { (error) in
                expect(error).to(beNil())
                done()
              }).disposed(by: self.disposeBag)
            }
          }
        }
      }
    }
  }
}
