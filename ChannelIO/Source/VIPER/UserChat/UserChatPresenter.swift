//
//  UserChatPresenter.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import UIKit
import SVProgressHUD
import Photos

class UserChatPresenter: NSObject, UserChatPresenterProtocol {  
  weak var view: UserChatViewProtocol? = nil
  var interactor: UserChatInteractorProtocol? = nil
  var router: UserChatRouterProtocol? = nil
  
  var userChatId: String?
  var userChat: CHUserChat?
  
  var state: ChatState = .idle
  var disposeBag = DisposeBag()
  
  func viewDidLoad() {
    //other socket or state event handling
    self.interactor?.chatEventSignal()
      .observeOn(MainScheduler.instance)
      .subscribe (onNext: { [weak self] chatEvent in
        guard let self = self else { return }
        switch chatEvent {
        case .state(let state):
          self.state = state
        case .messages(let messages, _):
          self.view?.display(messages: messages)
        case .manager(_):
          break
        case .chat(_):
          self.refreshChat()
        case .typing(let typers, _):
          self.view?.display(typers: typers)
        default:
          break
        }
        
      }).disposed(by: self.disposeBag)
  }

  func prepareDataSource() {
    self.interactor?.subscribeDataSource()
  }
  
  func cleanDataSource() {
    self.interactor?.unsunbscribeDataSource()
    self.interactor?.sendTyping(isStop: true)
  }
  
  func reload() {
    
  }
  
  private func isNewChat(with current: CHUserChat?, nextUserChat: CHUserChat?) -> Bool {
    return self.userChat == nil && nextUserChat == nil
  }
}

extension UserChatPresenter {
  func didClickOnFeedback(rating: String, from view: UIViewController?) {
    self.interactor?.sendFeedback(rating: rating)
  }
  
  func didClickOnOption(from view: UIViewController?) {
    guard let interactor = self.interactor else { return }
    
    self.router?.showOptionActionSheet(from: view).subscribe(onNext: { [weak self] assets in
      let messages = assets.map({ (asset) -> CHMessage in
        return CHMessage(chatId: self?.userChatId ?? "", user: mainStore.state.user, asset: asset)
      })
      
      if let userChatId = self?.userChatId, userChatId != "" {
        interactor.send(messages: messages).subscribe(onNext: { (_) in
          
        }, onError: { (error) in
          
        }).disposed(by: (self?.disposeBag)!)
      } else {
        //could be nudge or normal chat
        interactor.createChat().flatMap({ (chat) -> Observable<Any?> in
          return interactor.send(messages: messages)
        }).flatMap({ (completed) -> Observable<Bool?> in
          return .just(true)
        }).subscribe(onNext: { (completed) in
          
        }, onError: { (error) in
          
        }).disposed(by: (self?.disposeBag)!)
      }
    }).disposed(by: self.disposeBag)
  }

  func didClickOnRetry(for message: CHMessage?, from view: UIViewController?) {
    guard let interactor = self.interactor else { return }
    
    self.router?.showRetryActionSheet(from: view).subscribe(onNext: { retry in
      if retry == true {
        _ = interactor.send(message: message).subscribe()
      } else if retry == false {
        interactor.delete(message: message)
      }
    }).disposed(by: self.disposeBag)
  }
  
  func didClickOnVideo(with url: URL?, from view: UIViewController?) {
    guard let url = url else { return }
    self.router?.presentVideoPlayer(with: url, from: view)
  }
  
  func didClickOnFile(with message: CHMessage?, from view: UIViewController?) {
    guard var message = message else { return }
    guard let file = message.file else { return }
    
    if file.category == "video" {
      self.didClickOnVideo(with: file.fileUrl!, from: view)
      return
    }
    
    SVProgressHUD.showProgress(0)
    file.download().observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (fileURL, progress) in
        if let fileURL = fileURL {
          SVProgressHUD.dismiss()
          message.file?.urlInDocumentsDirectory = fileURL
          mainStore.dispatch(UpdateMessage(payload: message))
          self?.router?.pushFileView(with: fileURL, from: view)
        }
        if progress < 1 {
          SVProgressHUD.showProgress(progress)
        }
      }, onError: { (error) in
          SVProgressHUD.dismiss()
      }, onCompleted: {
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnImage(with url: URL?, photoUrls: [URL], from view: UIViewController?) {
    self.router?.presentImageViewer(with: url, photoUrls: photoUrls, from: view)
  }

  func didClickOnWeb(with url: String?, from view: UIViewController?) {
    guard let url = URL(string: url ?? "") else { return }
    UIApplication.shared.openURL(url)
  }
  
  func didClickOnTranslate(for message: CHMessage?) {
    guard let message = message else { return }
    self.interactor?.translate(for: message)
  }
  
  func didClickOnNewChat(with text: String, from view: UINavigationController?) {
    self.router?.showNewChat(with: text, from: view)
  }
  
  func didClickOnLeftButton(from view: UIViewController?) {
    self.router?.showOptionActionSheet(from: view)
    //interator send image(s)
  }
  
  func didClickOnRightButton(text: String, assets: [PHAsset]) {
    guard let interactor = self.interactor else { return }
    guard let chatId = self.userChatId else { return }
    let user = mainStore.state.user
    
    var messages = assets.enumerated().map { (index, asset) -> CHMessage in
      if index == 0 {
        return CHMessage(chatId: chatId, user: user, message: text, asset: asset)
      }
      return CHMessage(chatId: chatId, user: user, asset: asset)
    }
    
    if messages.count == 0 {
      messages = [CHMessage(chatId: chatId, user: user, message: text)]
    }
    
    if let userChat = self.userChat, userChat.isActive {
      interactor.send(messages: messages).subscribe().disposed(by: self.disposeBag)
    } else if self.userChat == nil {
      interactor.createChat().flatMap({ (userChat) -> Observable<Any?> in
        return interactor.send(messages: messages)
      }).flatMap({ (messages) -> Observable<Bool?> in
        return .just(true)
      }).subscribe(onNext: { (completed) in
        
      }, onError: { (error) in
        
      }).disposed(by: self.disposeBag)
    }
    else {
      mainStore.dispatch(RemoveMessages(payload: userChatId))
    }
  }
  
  func didClickOnActionButton(originId: String?, key: String?, value: String?) {
    guard let originId = originId, let key = key, let value = value else { return }
    guard let interactor = self.interactor else { return }
    
    interactor.send(text: value, originId: originId, key: key)
      .subscribe(onNext: { [weak self] (message) in
      self?.view?.display(messages: [])
    }, onError: { [weak self] (error) in
      self?.view?.display(error: error, visible: true)
    }).disposed(by: self.disposeBag)
  }
  
  func readyToDisplay() -> Observable<Bool>? {
    //load flow
    //1. join if needed (newly create or local chat just return true
    //2. fetch chat (newly create or local chat just return
    //3. fetch message (newly create or local chat just return
    //4. subscriber onNext ...
    return self.interactor?.readyToPresent()
  }

  func fetchMessages() {
    guard self.interactor?.canLoadMore() == true else { return }
    self.interactor?.fetchMessages()
  }
  
  func send(text: String, assets: [PHAsset]) {

  }
  
  func sendTyping(isStop: Bool) {
    self.interactor?.sendTyping(isStop: isStop)
  }
}

extension UserChatPresenter {
  func refreshChat() {
    let userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    
    self.view?.updateChatInfo(info: UserChatInfo(
      userChat: userChat,
      channel: mainStore.state.channel,
      plugin: mainStore.state.plugin,
      managers: [],
      textColor: mainStore.state.plugin.textUIColor))
  }
  
  func sendMessage(message: CHMessage, local: Bool = false) -> Observable<CHMessage?> {
    var message = message
    return Observable.create({ [weak self] (subscriber) in
      if local {
        subscriber.onNext(message)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      let signal = message.send()
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while sending message. Attempting to send again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (updated) in
        dlog("Message has been sent successfully")
        self?.sendTyping(isStop: true)
        subscriber.onNext(updated)
        subscriber.onCompleted()
      }, onError: { (error) in
        dlog("Message has been failed to send")
        message.state = .Failed
        self?.sendTyping(isStop: true)
        subscriber.onNext(message)
        subscriber.onCompleted()
      })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func processSendMessage(msg: String) -> Observable<CHUserChat?> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      let createChatSignal = self?.userChat?.isActive == true ?
        Observable.just(self?.userChat) : self?.interactor?.createChat()
      
      createChatSignal?
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .flatMap({ (userChat) -> Observable<CHMessage?> in
          guard let self = self, let userChat = userChat else { return .empty() }
          
          self.userChat = userChat
          self.userChatId = userChat.id
          let message = CHMessage.createLocal(chatId: userChat.id, text: msg)
          mainStore.dispatch(CreateMessage(payload: message))
          return self.sendMessage(message: message, local: false)
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (message) in
          mainStore.dispatch(CreateMessage(payload: message))
          subscriber.onNext(self?.userChat)
          subscriber.onCompleted()
        }, onError: { (error) in
          self?.state = .chatNotLoaded
          subscriber.onError(error)
        }).disposed(by: self!.disposeBag)
      return Disposables.create()
    })
  }
  
  private func processPostAction(originId: String?, key: String, value: String) {
    guard let chatId = self.userChatId else { return }
    let message = CHMessage.createLocal(chatId: chatId, text: value, originId: originId, key: key)
    mainStore.dispatch(CreateMessage(payload: message))
    
    self.sendMessage(message: message, local: false)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload:message))
      }, onError: { (error) in
        //handle error
      }).disposed(by: self.disposeBag)
  }
  
  func processNudgeKeepAction(){
    guard
      let chat = self.userChat,
      chat.fromNudge,
      let nudgeId = chat.nudgeId else {
        return
      }
    
    self.interactor?.createNudgeChat(nudgeId: nudgeId)
      .observeOn(MainScheduler.instance)
      .flatMap {( chatId) -> Observable<CHMessage?> in
        return UserChatPromise.keepNudge(userChatId: chatId)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }, onError: { (erro) in
        //?
      }).disposed(by: self.disposeBag)
  }
  
  private func processSupportBotAction(originId: String?, key: String?, value: String?) {
//    guard !self.isRequestingAction else { return }
//    self.isRequestingAction = true
    
    self.interactor?.createSupportBotChatIfNeeded(originId: originId)
      .observeOn(MainScheduler.instance)
      .flatMap({ (chat, message) -> Observable<CHMessage> in
        let msg = CHMessage.createLocal(chatId: chat!.id, text: value, originId: originId, key: key)
        mainStore.dispatch(CreateMessage(payload: msg))
        return CHSupportBot.reply(with: msg, actionId: message?.id)
      })
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while replying supportBot. Attempting to reply again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (updated) in
//        self?.isRequestingAction = false
        mainStore.dispatch(CreateMessage(payload: updated))
      }, onError: { [weak self] (error) in
//        self?.isRequestingAction = false
        //handle error
      }).disposed(by: self.disposeBag)
  }
  
  private func processUserChatAction(originId: String?, key: String?, value: String?) {
    guard var origin = messageSelector(state: mainStore.state, id: originId),
      let type = origin.action?.type,
      let key = key, let value = value else { return }
    
    var msg: CHMessage?
    guard let userChatId = self.userChatId else { return }
    if (type == .solve && key == "close") || type == .close {
      msg = CHMessage.createLocal(chatId: userChatId, text: value, originId: originId, key: key)
      mainStore.dispatch(CreateMessage(payload: msg))
    }
    
    if type == .solve && key == "close" {
      self.userChat?.close(mid: origin.id, requestId: msg?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { (error) in
          //handle error
        }).disposed(by: self.disposeBag)
    } else if type == .solve && key == "reopen" {
      origin.action?.closed = true
      mainStore.dispatch(UpdateMessage(payload: origin))
      if var updatedChat = userChatSelector(state: mainStore.state, userChatId: userChatId) {
        updatedChat.state = updatedChat.assigneeId == nil ? .unassigned : .assigned
        mainStore.dispatch(UpdateUserChat(payload: updatedChat))
      }
    } else if type == .close {
      self.userChat?.review(mid: origin.id, rating: ReviewType(rawValue: key)!, requestId:msg?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { (error) in
          
        }).disposed(by: self.disposeBag)
    }
  }
}
