//
//  WsServiceTests.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Quick
import Nimble
import RxSwift
//import ReSwift

@testable import ChannelIO

class WsServiceTests: QuickSpec {
  override func spec() {
    
    var disposable: Disposable?
    var readyDisposable: Disposable?
    let userChatId = "31243"
    
    beforeEach {
      PrefStore.setCurrentChannelId(channelId: "10")
      PrefStore.setCurrentVeilId(veilId: "58a154dec843f78f")
    }
    
    afterEach {
      disposable?.dispose()
      readyDisposable?.dispose()
    }
    
    it("join"){
//      let e = "joined"
//
//      waitUntil(timeout: 10) { done in
//        disposable = WsService.shared.listen()
//          .subscribe(onNext: { (event) in
//            print(event)
//            if event == e {
//              done ()
//            }
//          }, onError: { (error) in
//            expect(error).to(beNil())
//            done()
//          })
//
//        WsService.shared.connect()
//        readyDisposable = WsService.shared.ready()
//          .subscribe(onNext: { (event) in
//
//            WsService.sharedService.join(chatId: userChatId)
//          }, onError: { (error) in
//            expect(error).to(beNil())
//            done()
//          })
//      }
    }
  
    it("ready") {
//      let seq = "ready"
//
//      waitUntil(timeout:10) { done in
//        disposable = WsService.shared.listen()
//          .subscribe(onNext: { (event) in
//          print(event)
//
//          if event == seq {
//            done()
//          }
//        }, onError: { (error) in
//          expect(error).to(beNil())
//          done()
//        })
//
//        WsService.shared.connect()
//      }
    }
  
    it("join and leave") {
//      waitUntil(timeout: 10) { done in
//        WsService.shared.joined()
//          .delay(1.0, scheduler: MainScheduler.instance)
//          .subscribe(onNext: { (id) in
//            WsService.shared.leave(chatId: userChatId)
//          }, onError: { (error) in
//
//          })
//
//        disposable = WsService.shared.listen()
//          .subscribe(onNext: { (event, data) in
//          if event == "leaved" {
//            done()
//          }
//        }, onError: { (error) in
//          expect(error).to(beNil())
//          done()
//        })
//
//        WsService.shared.connect()
//        readyDisposable = WsService.shared.ready()
//          .subscribe(onNext: { (event) in
//          WsService.shared.join(chatId: userChatId)
//        }, onError: { (error) in
//          expect(error).to(beNil())
//          done()
//        })
//      }
    }

    it("user chat create") {
//      waitUntil(timeout: 10) { done in
//
//        readyDisposable = WsService.shared.ready()
//          .flatMap { UserChatPromise.createChat(pluginId: "7") }
//          .subscribe(onNext: { (event) in
//          _ = UserChatPromise.createChat()
//            .subscribe(onNext: { (response) in
//              //get response..
//            }, onError: { (error) in
//              expect(error).to(beNil())
//            })
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//
//        disposable = WsService.shared.listen()
//          .subscribe(onNext: { (event) in
////            print(event)
////            if event == "create" {
////              done()
////            }
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//
//        WsService.shared.connect()
//      }
    }
    
    it("user chat delete") {
//      waitUntil(timeout: 60) { done in
//        var userChatId = ""
//        
//        disposable = WsService.shared.listen()
//          .subscribe(onNext: { (event) in
//            print(event)
////
////            if event == "update" {
////              done()
////            }
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//        
//        readyDisposable = WsService.shared.ready()
//          .subscribe(onNext: { (event) in
//            _ = UserChatPromise.createChat()
//              .flatMap({ (response) -> Observable<Any?> in
//                userChatId = response.userChat?.id ?? ""
//                expect(userChatId).toNot(equal(""))
//                return UserChatPromise.remove(userChatId: userChatId)
//              })
//              .subscribe(onNext: { (response) in
//                
//              }, onError: { (error) in
//                expect(error).to(beNil())
//              })
//            
//          }, onError: { (error) in
//            expect(error).to(beNil())
//          })
//        
//        WsService.shared.connect()
//      }
    }

  }
}
