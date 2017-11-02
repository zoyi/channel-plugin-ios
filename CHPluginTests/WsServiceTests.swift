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

@testable import CHPlugin

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
      let e = "joined"
      
      waitUntil(timeout: 10) { done in
        disposable = WsService.sharedService.listen()
          .subscribe(onNext: { (event) in
            print(event)
            if event == e {
              done ()
            }
          }, onError: { (error) in
            expect(error).to(beNil())
            done()
          })
        
        WsService.sharedService.connect()
        readyDisposable = WsService.sharedService.ready()
          .subscribe(onNext: { (event) in
            
            WsService.sharedService.join(chatId: userChatId)
          }, onError: { (error) in
            expect(error).to(beNil())
            done()
          })
      }
    }
  
    it("ready") {
      let seq = "ready"
      
      waitUntil(timeout:10) { done in
        disposable = WsService.sharedService.listen()
          .subscribe(onNext: { (event) in
          print(event)
          
          if event == seq {
            done()
          }
        }, onError: { (error) in
          expect(error).to(beNil())
          done()
        })
        
        WsService.sharedService.connect()
      }
    }
  
    it("join and leave") {
      waitUntil(timeout: 10) { done in
        
        disposable = WsService.sharedService.listen()
          .subscribe(onNext: { (event) in
          if event == "joined" {
            WsService.sharedService.leave(chatId: userChatId)
          }
          
          if event == "leaved" {
            done()
          }
        }, onError: { (error) in
          expect(error).to(beNil())
          done()
        })
        
        WsService.sharedService.connect()
        readyDisposable = WsService.sharedService.ready()
          .subscribe(onNext: { (event) in
          WsService.sharedService.join(chatId: userChatId)
        }, onError: { (error) in
          expect(error).to(beNil())
          done()
        })
      }
    }

    it("user chat create") {
      waitUntil(timeout: 10) { done in

        readyDisposable = WsService.sharedService.ready()
          .subscribe(onNext: { (event) in
          _ = UserChatPromise.createChat()
            .subscribe(onNext: { (response) in
              //get response..
            }, onError: { (error) in
              expect(error).to(beNil())
            })
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        
        disposable = WsService.sharedService.listen()
          .subscribe(onNext: { (event) in
            print(event)
            if event == "create" {
              done()
            }
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        
        WsService.sharedService.connect()
      }
    }
    
    it("user chat delete") {
      waitUntil(timeout: 60) { done in
        var userChatId = ""
        
        disposable = WsService.sharedService.listen()
          .subscribe(onNext: { (event) in
            print(event)
            
            if event == "update" {
              done()
            }
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        
        readyDisposable = WsService.sharedService.ready()
          .subscribe(onNext: { (event) in
            _ = UserChatPromise.createChat()
              .flatMap({ (response) -> Observable<Any?> in
                userChatId = response.userChat?.id ?? ""
                expect(userChatId).toNot(equal(""))
                return UserChatPromise.remove(userChatId: userChatId)
              })
              .subscribe(onNext: { (response) in
                
              }, onError: { (error) in
                expect(error).to(beNil())
              })
            
          }, onError: { (error) in
            expect(error).to(beNil())
          })
        
        WsService.sharedService.connect()
      }
    }

  }
}
