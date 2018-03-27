//
//  UserChatPresenter.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import DKImagePickerController
import UIKit
import CHPhotoBrowser

class UserChatPresenter: NSObject, UserChatPresenterProtocol {  
  weak var view: UserChatViewProtocol? = nil
  var interactor: UserChatInteractorProtocol? = nil
  var router: UserChatRouterProtocol? = nil
  
  var userChatId: String?
  var userChat: CHUserChat?
  
  var disposeBag = DisposeBag()
  
  func viewDidLoad() {
    //fetchWelcomeInfoIfNeeded
    let userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    let userChats = userChatsSelector(
      state: mainStore.state,
      showCompleted: mainStore.state.userChatsState.showCompletedChats
    )
    
    self.view?.setChatInfo(info: UserChatInfo(
      userChat: userChat,
      channel: mainStore.state.channel,
      plugin: mainStore.state.plugin,
      managers: [],
      showSettings: userChats.count == 0,
      textColor: mainStore.state.plugin.textUIColor))
      
    self.interactor?.chatEventSignal()
      .observeOn(MainScheduler.instance)
      .subscribe (onNext: { [weak self] chatEvent in
        switch chatEvent {
        case .messages(let messages, let nextSeq):
          break
        case .manager(let managers):
          break
        case .chat(let chat):
          //if resolve
          //if close
          break
        case .typing(let typers, let animated):
          break
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
}

extension UserChatPresenter {
  func didClickOnFeedback(rating: String, from view: UIViewController?) {
    self.interactor?.sendFeedback(rating: rating)
  }
  
  func didClickOnOption(from view: UIViewController?) {
    self.router?.showOptionActionSheet(from: view).subscribe(onNext: { assets in
//      func uploadImage(_ userChatId: String) {
//        let messages = assets.map({ (asset) -> CHMessage in
//          return CHMessage(chatId: self.userChatId, guest: mainStore.state.guest, asset: asset)
//        })
//
//        messages.forEach({ mainStore.dispatch(CreateMessage(payload: $0)) })
//        //TODO: rather create array of signal and trigger in order
//        //self?.chatManager.sendMessageRecursively(allMessages: messages, currentIndex: 0)
//      }
//
//      if let userChatId = self?.userChatId {
//        uploadImage(userChatId)
//      } else {
//        self?.chatManager.createChat(completion: { (userChatId) in
//          self?.userChatId = userChatId
//          if let userChatId = userChatId {
//            uploadImage(userChatId)
//          } else {
//            self?.chatManager.state = .chatNotLoaded
//          }
//        })
//      }
    }).disposed(by: self.disposeBag)
  }

  func didClickOnRetry(for message: CHMessage?, from view: UIViewController?) {
    self.router?.showRetryActionSheet(from: view).subscribe(onNext: { [weak self] retry in
      if retry == true {
        self?.interactor?.send(message: message)
      } else if retry == false {
        self?.interactor?.delete(message: message)
      }
    }).disposed(by: self.disposeBag)
  }
  
  func didClickOnManager(from view: UIViewController?) { }
  
  func didClickOnFile(with message: CHMessage?, from view: UIViewController?) {
    
  }
  
  func didClickOnImage(with url: URL?, from view: UIViewController?) {
    self.router?.showImageViewer(
      with: url,
      photoUrls: self.interactor?.photoUrls ?? [],
      from: view,
      dataSource: self.interactor as! MWPhotoBrowserDelegate)
  }
  
  func didClickOnWeb(with url: String?, from view: UIViewController?) {
    guard let url = URL(string: url ?? "") else { return }
    UIApplication.shared.openURL(url)
  }
  
  func didClickOnTranslate(for message: CHMessage?) {
    guard let message = message else { return }
    self.interactor?.translate(for: message)
  }
  
  func fetchMessages() {
    guard self.interactor?.canLoadMore() == true else { return }
    self.interactor?.fetchMessages()
  }
  
  func send(text: String, assets: [DKAsset]) {
    guard let interactor = self.interactor else { return }
    
    if let userChat = self.userChat, userChat.isActive() {
      interactor.send(text: text, assets: assets)
    } else if self.userChat == nil {
      interactor.createChat().subscribe(onNext: { [weak self] (userChat) in
        self?.userChat = userChat
        self?.userChatId = userChat.id
        interactor.send(text: text, assets: assets)
      }, onError: { error in
        
      }).disposed(by: self.disposeBag)
    }
    else {
      mainStore.dispatch(RemoveMessages(payload: userChatId))
      //open new chat if text
      //self.newChatSubject.onNext(self.textView.text)
    }
  }
  
  func sendTyping(isStop: Bool) {
    self.interactor?.sendTyping(isStop: isStop)
  }
}
