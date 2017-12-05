//
//  ChatManager.swift
//  CHPlugin
//
//  Created by Haeun Chung on 12/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

enum ChatElement {
  case message(obj: CHMessage?)
  case manager(obj: CHManager?)
  case session(obj: CHSession?)
  case chat(obj: CHUserChat?)
  case typing(obj: [CHEntity]?, animated: Bool)
}

enum ChatState {
  case idle
  case chatLoading
  case chatLoaded
  case chatNotLoaded
  case chatJoining
  case waitingSocket
  case messageLoading
  case messageNotLoaded
  case chatReady
}

protocol ChatDelegate : class {
  func updateFor(element: ChatElement)
}

class ChatManager {
  var chatId = ""
  var chatType = ""
  var chat: CHUserChat? = nil
  let disposeBag = DisposeBag()
  
  fileprivate var typingPersons = [CHEntity]()
  fileprivate var timeStorage = [String: Timer]()
  fileprivate var animateTyping = false
  var typers: [CHEntity] {
    get {
      return self.typingPersons
    }
  }
  
  weak var delegate: ChatDelegate? = nil
  
  init(id: String?, type: String = "UserChat"){
    self.chatId = id ?? ""
    self.chatType = type
    
    self.observeSocketEvents()
  }
  
  fileprivate func observeSocketEvents() {
    self.observeMessageEvents()
    self.observeChatEvents()
    self.observeSessionEvents()
    self.observeTypingEvents()
  }
  
  fileprivate func observeMessageEvents() {
    WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        guard let s = self else { return }
        
        let typing = CHTypingEntity.transform(from: message)
        if let index = s.getTypingIndex(of: typing) {
          let person = s.typingPersons.remove(at: index)
          s.removeTimer(with: person)
          s.delegate?.updateFor(element: .typing(obj: self?.typingPersons, animated: s.animateTyping))
        }
        
        s.delegate?.updateFor(element: .message(obj: message))
      }).disposed(by: self.disposeBag)
  }
  
  fileprivate func observeChatEvents() { }
  fileprivate func observeSessionEvents() { }
  
  fileprivate func observeTypingEvents() {
    WsService.shared.typingSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (typingEntity) in
        guard let s = self else { return }
        if typingEntity.action == "stop" {
          if let index = s.getTypingIndex(of: typingEntity) {
            let person = s.typingPersons.remove(at: index)
            s.removeTimer(with: person)
          }
        }
        else if typingEntity.action == "start" {
          if let manager = personSelector(
            state: mainStore.state,
            personType: typingEntity.personType ?? "",
            personId: typingEntity.personId) as? CHManager {
            if s.getTypingIndex(of: typingEntity) == nil {
              s.typingPersons.append(manager)
            }
            s.addTimer(with: manager, delay: 15)
          }
        }
        //reload row not section only if visible
        s.delegate?.updateFor(element: .typing(obj: s.typingPersons, animated: s.animateTyping))
      }).disposed(by: self.disposeBag)
  }
}

extension ChatManager {
  public func sendTyping(isStop: Bool) {
    WsService.shared.sendTyping(
      chat: self.chat,
      isStop: isStop
    )
  }
  
  fileprivate func addTimer(with person: CHEntity, delay: TimeInterval) {
    let timer = Timer.scheduledTimer(
      timeInterval: delay,
      target: self,
      selector: #selector(self.expired(_:)),
      userInfo: [person],
      repeats: false
    )
    
    if let t = self.timeStorage[person.key] {
      t.invalidate()
    }
    
    self.timeStorage[person.key] = timer
  }
  
  fileprivate func removeTimer(with person: CHEntity?) {
    guard let person = person else { return }
    if let t = self.timeStorage.removeValue(forKey: person.key) {
      t.invalidate()
    }
  }
  
  public func resetTypingInfo() {
    self.timeStorage.forEach { (k, t) in
      t.invalidate()
    }
    self.typingPersons.removeAll()
    self.timeStorage.removeAll()
  }
  
  @objc fileprivate func expired(_ timer: Timer) {
    guard let params = timer.userInfo as? [Any] else { return }
    guard let person = params[0] as? CHEntity else { return }
    
    timer.invalidate()
    if let index = self.typingPersons.index(where: { (p) in
      return p.id == person.id && p.kind == person.kind
    }) {
      self.typingPersons.remove(at: index)
      self.timeStorage.removeValue(forKey: person.key)
      self.delegate?.updateFor(element: .typing(obj: nil, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.index(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }
}
