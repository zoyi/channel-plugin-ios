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
import SVProgressHUD

class UserChatPresenter: NSObject, UserChatPresenterProtocol {
  weak var view: UserChatViewProtocol? = nil
  var interactor: UserChatInteractorProtocol? = nil
  var router: UserChatRouterProtocol? = nil
  
  var userChatId: String?
  var userChat: CHUserChat?
  
  var disposeBag = DisposeBag()
  
  func viewDidLoad() {
    //fetchWelcomeInfoIfNeeded
    self.refreshChat()
      
    self.interactor?.chatEventSignal()
      .observeOn(MainScheduler.instance)
      .subscribe (onNext: { [weak self] chatEvent in
        switch chatEvent {
        case .messages(let messages, _):
          self?.userChat?.readAll()
          self?.view?.display(messages: messages)
          break
        case .manager(_):
          break
        case .chat(let chat):
          self?.refreshChat()
          if chat?.isResolved() == true {
            //display resolved
          } else if chat?.isClosed() == true {
            //display closed
          }
          break
        case .typing(let typers, _):
          self?.view?.display(typers: typers)
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
    guard let interactor = self.interactor else { return }
    
    self.router?.showOptionActionSheet(from: view).subscribe(onNext: { [weak self] assets in
      let messages = assets.map({ (asset) -> CHMessage in
        return CHMessage(chatId: self?.userChatId ?? "", guest: mainStore.state.guest, asset: asset)
      })
      
      if let userChatId = self?.userChatId, userChatId != "" {
        interactor.send(messages: messages).subscribe(onNext: { (_) in
          
        }, onError: { (error) in
          
        }, onCompleted: {
          
        }).disposed(by: (self?.disposeBag)!)
      } else {
        interactor.createChat().flatMap({ (chat) -> Observable<Any?> in
          return interactor.send(messages: messages)
        }).flatMap({ (completed) -> Observable<Bool?> in
          return interactor.requestProfileBot()
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
  
  func didClickOnManager(from view: UIViewController?) { }
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
  
  func didClickOnImage(with url: URL?, from view: UIViewController?) {
    self.router?.presentImageViewer(
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
  
  func didClickOnNewChat(with text: String, from view: UINavigationController?) {
    self.router?.showNewChat(with: text, from: view)
  }
  
  func didClickOnSettings(from view: UIViewController?) {
    self.router?.presentSettings(from: view)
  }
  
  func readyToDisplay() -> Observable<Any?>? {
    return self.interactor?.readyToPresent()
  }

  func fetchMessages() {
    guard self.interactor?.canLoadMore() == true else { return }
    self.interactor?.fetchMessages()
  }
  
  func send(text: String, assets: [DKAsset]) {
    guard let interactor = self.interactor else { return }
    
    if let userChat = self.userChat, userChat.isActive() {
      interactor.send(text: text, assets: assets)
        .subscribe().disposed(by: self.disposeBag)
    } else if self.userChat == nil {
      interactor.createChat().flatMap({ (userChat) -> Observable<[CHMessage]> in
        return interactor.send(text: text, assets: assets)
      }).flatMap({ (messages) -> Observable<Bool?> in
        return interactor.requestProfileBot()
      }).subscribe(onNext: { (completed) in
        
      }, onError: { (error) in
        
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

extension UserChatPresenter {
  func refreshChat() {
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
  }
}
